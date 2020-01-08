//D FF
module d_ff(clk, rst, en, d, q);
parameter WIDTH = 32;

input clk, rst, en;
input [WIDTH-1:0] d;
output [WIDTH-1:0] q;

wire clk, rst, en;
wire [WIDTH-1:0] d;
reg [WIDTH-1:0] q;

always @(posedge clk)
begin
	if (rst == 1'b1) begin
		q <= 0;
	end else if (en == 1'b1) begin
		q <= d;
	end

end

endmodule


