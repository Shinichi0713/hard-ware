module seven(inp, a, b, c, d, e, f, g);
  input [2:0] inp;
  output a, b, c, d, e, f, g;

  reg a, b, c, d, e, f, g;

always@ (inp) 
begin
  case(inp)
    3'b000: 
    begin
      a <= 1;
      b <= 1;
      c <= 1;
      d <= 1;
      e <= 1;
      f <= 1;
      g <= 0;
    end 
    3'b001:
    begin
      a <= 0;
      b <= 1;
      c <= 1;
      d <= 0;
      e <= 0;
      f <= 0;
      g <= 0;
    end
    3'b010:
    begin
      a <= 1;
      b <= 1;
      c <= 0;
      d <= 1;
      e <= 1;
      f <= 0;
      g <= 1;
    end
    3'b011:
    begin
      a <= 1;
      b <= 1;
      c <= 1;
      d <= 1;
      e <= 0;
      f <= 0;
      g <= 1;
    end
    default:
    begin
      a <= 1;
      b <= 0;
      c <= 0;
      d <= 1;
      e <= 1;
      f <= 1;
      g <= 1;
    end
  endcase
end

endmodule
