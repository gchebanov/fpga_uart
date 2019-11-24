module uart_tx # (
	parameter CLK_FREQ = 50_000_000,
	parameter BAUD_RATE = 9600,
	parameter DATA_W = 8
) (
	input wire clk,
	input wire nrst,
	input wire [DATA_W-1:0] data,
	input reg data_valid,
	output reg data_ready,
	output reg txd
);

localparam N = CLK_FREQ / BAUD_RATE;
reg cnt0;
reg last_state;
reg [$clog2(N)-1:0] cnt;
reg [$clog2(DATA_W)-1:0] state;
reg [3:0] ostate;

always @(posedge clk) begin
	cnt0 <= (cnt <= 1);
	if (!nrst) begin
		cnt <= 0;
		state <= 0;
		ostate <= 0;
		data_ready <= 0;
		txd <= 1;
	end else if ((ostate == 0) && data_valid) begin
		cnt0 <= 0;
		cnt <= N;
		ostate <= 1;
		txd <= 0; // start bit
	end else if (ostate == 1) begin
		if (cnt0) begin
			cnt0 <= 0;
			cnt <= N;
			state <= 0;
			ostate <= 2;
			txd <= data[0];
		end else begin
			cnt <= cnt - 1;
		end
	end else if (ostate == 2) begin
		if (cnt0) begin
			cnt0 <= 0;
			cnt <= N;
			if (last_state) begin
				last_state <= 0;
				state <= 0;
				ostate <= 3;
				txd <= 1; // stop bit
			end else begin
				last_state <= (state == DATA_W - 2 ? 1 : 0);
				state <= state + 1;
				ostate <= 2;
				txd <= data[state + 1];
			end
		end else begin
			cnt <= cnt - 1;
		end
	end else if (ostate == 3) begin
		if (cnt0) begin
			cnt0 <= 0;
			ostate <= 0;
			data_ready <= 1;
		end else begin
			cnt <= cnt - 1;
		end
	end
end

endmodule // uart_tx