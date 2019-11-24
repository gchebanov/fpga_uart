module uart_rx_dbg # (
	parameter CLK_FREQ = 50_000_000,
	parameter BAUD_RATE = 9_600
) (
	input wire clk,
	input wire nrst,
	input wire rxd,
	output reg [15:0] data,
	output reg data_v
);

localparam N = CLK_FREQ / BAUD_RATE;
reg [15:0] cnt;
wire good_cnt;
reg rxd_r;

assign good_cnt = (N * 3 / 4 <= cnt) && (cnt <= N * 5 / 4);

always @(posedge clk) begin
	rxd_r <= rxd;
	data_v <= 0;
	if (!nrst) begin
		cnt <= 0;
	end else if (rxd_r != rxd) begin
		if (good_cnt) begin
			data <= cnt;
			data_v <= 1;
		end
		cnt <= 0;
	end else begin
		cnt <= (cnt != '1) ? (cnt + 1) : '1;
	end
end

endmodule // uart_rx_dbg