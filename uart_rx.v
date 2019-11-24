module uart_rx # (
	parameter CLK_FREQ = 50_000_000,
	parameter BAUD_RATE = 9_600
) (
	input wire clk,
	input wire nrst,
	input wire rxd,
	output reg [7:0] data,
	output reg data_v
);

localparam DATA_W = 8;
localparam N = CLK_FREQ / BAUD_RATE;
localparam N3_2 = (3 * CLK_FREQ) / 2 / BAUD_RATE;

reg state_input;	
reg [2:0] state; // clog(DATA_W-1) bits
reg [$clog2(N3_2)-1:0] cnt;
reg cnt_low;

always @(posedge clk) begin
	data_v <= 0;
	cnt_low <= (cnt <= 1);
	if (!nrst) begin
		state_input <= 0;
		state <= 0;
		cnt <= 0;
		data <= 0;
	end else if (!state_input) begin
		if (cnt_low) begin // wait after last bit
			if (rxd == 0) begin
				state_input <= 1;
				state <= 0; // not nessesary
				cnt <= N3_2;
				cnt_low <= 0;
			end
		end else begin
			cnt <= cnt - 1;
		end
	end else begin
		if (cnt_low) begin
			data <= {rxd, data[7:1]};
			state_input <= (state != DATA_W - 1);
			state <= state + 1;
			cnt <= N;
			cnt_low <= 0;
			data_v <= (state == DATA_W - 1);
		end else begin
			cnt <= cnt - 1;
		end
	end
end

endmodule // uart_rx