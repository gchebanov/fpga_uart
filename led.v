module led (
	input wire clk,
	input wire nrst,
	input reg [3:0] data [7:0],
	output wire [7:0] led_segments,
	output wire [7:0] led_enable
);

reg [15:0] cnt;
reg [3:0] digit;
reg [7:0] segments;
reg [7:0] enable;

assign led_segments = segments;
assign led_enable = enable;

always @(posedge clk) begin
	if (!nrst) begin
		cnt <= 0;
		digit <= '1;
		enable <= '1;
	end else begin
		cnt <= cnt + 1;
		digit <= data[cnt[15:13]];
		for (int i = 0; i < 8; i++) begin
			enable[i] <= (cnt[15:13] != i);
		end
	end
end

always @(posedge clk) begin
	if (!nrst) begin
		segments <= '1;
	end else	case (digit)
		0: segments <= 8'b1100_0000;
		1: segments <= 8'b1111_1001;
		2: segments <= 8'b1010_0100;
		3: segments <= 8'b1011_0000;
		4: segments <= 8'b1001_1001;
		5: segments <= 8'b1001_0010;
		6: segments <= 8'b1000_0010;
		7: segments <= 8'b1111_1000;
		8: segments <= 8'b1000_0000;
		9: segments <= 8'b1001_0000;
		10:segments <= 8'b1000_1000;
		11:segments <= 8'b1000_0011;
		12:segments <= 8'b1100_0110;
		13:segments <= 8'b1010_0001;
		14:segments <= 8'b1000_0110;
		15:segments <= 8'b1000_1110;
	endcase // case (digit)
end

endmodule // led