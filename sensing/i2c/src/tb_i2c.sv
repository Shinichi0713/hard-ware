`timescale 1us / 1ns

//------------------------------------------------------------
// I2C Testbench: Master reads temperature from BME280 slave
//------------------------------------------------------------
module tb_i2c;

    logic clk = 0;
    logic rst_n;

    // I2C bus
    wire sda;
    wire scl;

    // Master control
    logic        start_tx;
    logic [6:0]  slave_addr;
    logic        rw;
    logic [7:0]  reg_addr;
    logic [4:0]  read_len;
    logic [7:0]  read_data [0:7];
    logic [4:0]  read_count;
    logic        busy;
    logic        done;
    logic        nack_detected;

    // Clock generation: 1MHz
    always #0.5us clk = ~clk;

    // Pull-up resistors (modeled as weak pull-ups)
    pullup(sda);
    pullup(scl);

    // DUT: I2C Master
    i2c_master #(
        .CLK_FREQ(1_000_000),
        .I2C_FREQ(100_000)
    ) dut_master (
        .clk(clk),
        .rst_n(rst_n),
        .sda(sda),
        .scl(scl),
        .start_tx(start_tx),
        .slave_addr(slave_addr),
        .rw(rw),
        .reg_addr(reg_addr),
        .read_len(read_len),
        .read_data(read_data),
        .read_count(read_count),
        .busy(busy),
        .done(done),
        .nack_detected(nack_detected)
    );

    // DUT: BME280 Slave
    i2c_slave_bme280 #(
        .SLAVE_ADDR(7'h76)
    ) dut_slave (
        .sda(sda),
        .scl(scl)
    );

    // Test sequence
    initial begin
        $dumpfile("i2c_waveform.vcd");
        $dumpvars(0, tb_i2c);

        $display("========================================");
        $display("  I2C Master-Slave Simulation");
        $display("  Reading BME280 Temperature Register");
        $display("========================================");

        // Initialize
        rst_n = 0;
        start_tx = 0;
        slave_addr = 7'h76;
        rw = 1'b1;          // Read mode
        reg_addr = 8'hFA;   // Temperature MSB register
        read_len = 3;       // Read 3 bytes (MSB, LSB, XLSB)

        #10us rst_n = 1;

        // Wait for reset release
        @(posedge clk);

        // Start I2C transaction
        $display("\n[Time=%0t] Starting I2C read from BME280 (addr=0x76, reg=0xFA)", $time);
        start_tx = 1;
        @(posedge clk);
        start_tx = 0;

        // Wait for transaction complete
        wait(done == 1'b1);
        #10us;

        // Display results
        $display("\n--- Transaction Complete ---");
        $display("  NACK detected: %b", nack_detected);
        $display("  Bytes read: %0d", read_count);

        if (read_count >= 3) begin
            logic [23:0] temp_raw;
            temp_raw = {read_data[0], read_data[1], read_data[2]};
            $display("  Raw Temperature (24-bit): 0x%06X", temp_raw);
            $display("  Byte[0xFA]: 0x%02X (MSB)", read_data[0]);
            $display("  Byte[0xFB]: 0x%02X (LSB)", read_data[1]);
            $display("  Byte[0xFC]: 0x%02X (XLSB)", read_data[2]);
        end

        $display("\n--- Simulation Complete ---");
        #50us;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #5000us;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule