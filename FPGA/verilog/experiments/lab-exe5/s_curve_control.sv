//////////////////////////////////////////////////////////////////////////////
// Stepper Motor S-Curve (Jerk-Limited) Profile Generator
// - Phase accumulator based step pulse generation (no division required)
// - Symmetric S-curve acceleration/deceleration
//////////////////////////////////////////////////////////////////////////////

module stepper_scurve #(
    parameter int CLK_HZ      = 50_000_000, // System clock frequency (Hz)
    parameter int PRESCALER   = 100,        // Control loop prescaler (CLK_HZ/PRESCALER = servo rate)
    parameter int VELOCITY_W  = 32,         // Velocity data width
    parameter int POS_WIDTH   = 32          // Position counter width
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // Command interface
    input  logic [POS_WIDTH-1:0]    target_position,  // Target step count (absolute)
    input  logic                    start,            // Pulse to start motion
    input  logic                    dir_polarity,     // 0: CW, 1: CCW (or vice versa depending on driver)

    // Profile limits (fixed-point: assume 16.16 for all below if not specified)
    // These are in units of "velocity units" and updated every control cycle.
    input  logic [VELOCITY_W-1:0]   max_velocity,     // Maximum velocity (phase increment per clock)
    input  logic [VELOCITY_W-1:0]   max_acceleration, // Maximum acceleration (velocity change per cycle)
    input  logic [VELOCITY_W-1:0]   max_jerk,         // Maximum jerk (acceleration change per cycle)

    // Status
    output logic [POS_WIDTH-1:0]    current_position,
    output logic                    busy,
    output logic                    done_pulse,       // High for one clock when motion completes

    // Hardware interface to motor driver (e.g., A4988, TMC2209, etc.)
    output logic                    step_out,
    output logic                    dir_out
);

    // -------------------------------------------------------------------------
    // Fixed-point interpretation (for documentation; arithmetic is plain unsigned/signed)
    // We use Q32.0 for position, and treat velocity/acceleration as unsigned magnitudes.
    // -------------------------------------------------------------------------

    typedef enum logic [3:0] {
        ST_IDLE,
        ST_ACCEL_JERK_UP,    // Increasing acceleration (+jerk)
        ST_ACCEL_CONST,      // Constant acceleration
        ST_ACCEL_JERK_DOWN,  // Decreasing acceleration (-jerk) toward zero
        ST_CONST_SPEED,      // Constant speed
        ST_DECEL_JERK_UP,    // Increasing deceleration (-jerk)
        ST_DECEL_CONST,      // Constant deceleration
        ST_DECEL_JERK_DOWN,  // Decreasing deceleration (+jerk) toward zero
        ST_DONE
    } state_t;

    state_t state, next_state;

    // -------------------------------------------------------------------------
    // Prescaler to generate control-rate clock enable
    // -------------------------------------------------------------------------
    logic [$clog2(PRESCALER)-1:0] prescaler_cnt;
    logic                         tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler_cnt <= '0;
            tick          <= 1'b0;
        end else begin
            if (prescaler_cnt == PRESCALER-1) begin
                prescaler_cnt <= '0;
                tick          <= 1'b1;
            end else begin
                prescaler_cnt <= prescaler_cnt + 1'b1;
                tick          <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Profile generation variables
    // -------------------------------------------------------------------------
    logic signed [VELOCITY_W-1:0]   velocity;           // Current velocity (magnitude, always >=0 during motion)
    logic signed [VELOCITY_W-1:0]   acceleration;       // Current acceleration
    logic signed [VELOCITY_W-1:0]   jerk;              // Current applied jerk (+max_jerk or -max_jerk)

    logic        [POS_WIDTH-1:0]    target_pos_latch;
    logic        [POS_WIDTH:0]      distance_to_go;    // Extra bit to avoid underflow in comparison
    logic        [POS_WIDTH-1:0]    accel_distance;    // Distance traveled during acceleration phase
    logic                           dir_latch;

    // Phase accumulator for step generation
    logic [VELOCITY_W-1:0]          phase_acc;
    logic                           step_pulse;

    // -------------------------------------------------------------------------
    // Step pulse generation via phase accumulator
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= '0;
            step_pulse<= 1'b0;
        end else begin
            step_pulse <= 1'b0; // default
            if (velocity > 0) begin
                {step_pulse, phase_acc} <= phase_acc + velocity[VELOCITY_W-1:0];
            end else begin
                phase_acc <= phase_acc;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Position counter (up/down based on direction)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_position <= '0;
        end else begin
            if (step_pulse) begin
                if (dir_latch == 1'b0)
                    current_position <= current_position + 1'b1;
                else
                    current_position <= current_position - 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Distance-to-go calculation
    // -------------------------------------------------------------------------
    always_comb begin
        if (target_pos_latch >= current_position)
            distance_to_go = (target_pos_latch - current_position);
        else
            distance_to_go = (current_position - target_pos_latch);
    end

    // -------------------------------------------------------------------------
    // State machine sequential logic
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state            <= ST_IDLE;
            velocity         <= '0;
            acceleration     <= '0;
            jerk             <= '0;
            target_pos_latch <= '0;
            accel_distance   <= '0;
            dir_latch        <= 1'b0;
            done_pulse       <= 1'b0;
        end else begin
            done_pulse <= 1'b0; // default

            case (state)
                // -----------------------------------------------------------------
                ST_IDLE: begin
                    velocity     <= '0;
                    acceleration <= '0;
                    jerk         <= '0;
                    if (start) begin
                        target_pos_latch <= target_position;
                        dir_latch        <= dir_polarity;
                        state            <= ST_ACCEL_JERK_UP;
                    end
                end

                // -----------------------------------------------------------------
                // 1. Acceleration phase: increasing acceleration (positive jerk)
                // -----------------------------------------------------------------
                ST_ACCEL_JERK_UP: begin
                    if (tick) begin
                        // Apply positive jerk until reaching max acceleration
                        if (acceleration < $signed({1'b0, max_acceleration})) begin
                            acceleration <= acceleration + $signed({1'b0, max_jerk});
                            jerk         <= $signed({1'b0, max_jerk});
                        end else begin
                            acceleration <= $signed({1'b0, max_acceleration});
                            jerk         <= '0;
                        end

                        // Integrate jerk -> accel, accel -> velocity
                        if (acceleration < $signed({1'b0, max_acceleration})) begin
                            velocity <= velocity + acceleration;
                        end else begin
                            // Once accel is saturated, move to constant acceleration region
                            if (velocity < ($signed({1'b0, max_velocity}) - acceleration))
                                velocity <= velocity + acceleration;
                            else
                                state <= ST_ACCEL_JERK_DOWN;
                        end

                        // Safety: if we are already near target, skip to deceleration
                        if (distance_to_go <= (velocity >> 16)) // rough heuristic
                            state <= ST_DECEL_JERK_UP;
                    end
                end

                // -----------------------------------------------------------------
                // 2. Constant acceleration phase
                // -----------------------------------------------------------------
                ST_ACCEL_CONST: begin
                    if (tick) begin
                        jerk <= '0;
                        if (velocity < ($signed({1'b0, max_velocity}) - acceleration))
                            velocity <= velocity + acceleration;
                        else
                            state <= ST_ACCEL_JERK_DOWN;
                    end
                end

                // -----------------------------------------------------------------
                // 3. Acceleration phase: decreasing acceleration (negative jerk)
                // -----------------------------------------------------------------
                ST_ACCEL_JERK_DOWN: begin
                    if (tick) begin
                        if (acceleration > $signed('0)) begin
                            acceleration <= acceleration - $signed({1'b0, max_jerk});
                            jerk         <= -$signed({1'b0, max_jerk});
                            velocity     <= velocity + acceleration;
                        end else begin
                            acceleration <= '0;
                            jerk         <= '0;
                            velocity     <= velocity; // hold
                            accel_distance <= current_position; // Remember distance spent in accel
                            state        <= ST_CONST_SPEED;
                        end
                    end
                end

                // -----------------------------------------------------------------
                // 4. Constant speed
                // -----------------------------------------------------------------
                ST_CONST_SPEED: begin
                    if (tick) begin
                        jerk     <= '0;
                        velocity <= $signed({1'b0, max_velocity});

                        // Symmetric S-curve: start deceleration when remaining distance
                        // is less than or equal to the distance used during acceleration.
                        // For more precision, accel_distance could be stored as a dedicated
                        // counter during the accel phases, but this symmetric approximation
                        // works well for many applications.
                        if (distance_to_go <= accel_distance)
                            state <= ST_DECEL_JERK_UP;
                    end
                end

                // -----------------------------------------------------------------
                // 5. Deceleration phase: increasing deceleration (negative jerk)
                // -----------------------------------------------------------------
                ST_DECEL_JERK_UP: begin
                    if (tick) begin
                        if (-acceleration < $signed({1'b0, max_acceleration})) begin
                            acceleration <= acceleration - $signed({1'b0, max_jerk});
                            jerk         <= -$signed({1'b0, max_jerk});
                        end else begin
                            acceleration <= -$signed({1'b0, max_acceleration});
                            jerk         <= '0;
                        end

                        if (velocity > (acceleration + $signed({1'b0, max_jerk})))
                            velocity <= velocity + acceleration; // acceleration is negative here
                        else
                            state <= ST_DECEL_JERK_DOWN;
                    end
                end

                // -----------------------------------------------------------------
                // 6. Constant deceleration
                // -----------------------------------------------------------------
                ST_DECEL_CONST: begin
                    if (tick) begin
                        jerk <= '0;
                        if (velocity > (-acceleration))
                            velocity <= velocity + acceleration; // acceleration is negative
                        else
                            state <= ST_DECEL_JERK_DOWN;
                    end
                end

                // -----------------------------------------------------------------
                // 7. Deceleration phase: decreasing deceleration (positive jerk)
                // -----------------------------------------------------------------
                ST_DECEL_JERK_DOWN: begin
                    if (tick) begin
                        if (acceleration < $signed('0)) begin
                            acceleration <= acceleration + $signed({1'b0, max_jerk});
                            jerk         <= $signed({1'b0, max_jerk});
                            if (velocity > $signed({1'b0, max_jerk}))
                                velocity <= velocity + acceleration;
                            else
                                velocity <= '0;
                        end else begin
                            acceleration <= '0;
                            jerk         <= '0;
                            velocity     <= '0;
                            state        <= ST_DONE;
                        end
                    end
                end

                // -----------------------------------------------------------------
                ST_DONE: begin
                    done_pulse <= 1'b1;
                    state      <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Output assignments
    // -------------------------------------------------------------------------
    assign busy     = (state != ST_IDLE) && (state != ST_DONE);
    assign dir_out  = dir_latch;
    assign step_out = step_pulse;

endmodule