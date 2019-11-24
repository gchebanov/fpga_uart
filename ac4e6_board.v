module ac4e6_board (
	input wire clk50,

	input wire [3:0] key,
	input wire [7:0] switch,

	input wire ps2_data,
	input wire ps2_sdck,

	input wire ch340_rx,
	output wire ch340_tx,

	output wire buzzer,

	output wire [7:0] led_segments,
	output wire [7:0] led_enable,

	output wire [2:0] vga_rgb,
	output wire vga_hsync,
	output wire vga_vsync,

	output wire [11:0] led
);

assign buzzer = '1;
assign vga_rgb = '1;
assign vga_hsync = '1;
assign vga_vsync = '1;
assign led = '1;

wire nrst, rst;
assign nrst = key[2];
assign rst = !nrst;

reg [7:0] uart_q;
reg uart_qv;
uart_rx i_uart_rx(clk50, nrst, ch340_rx, uart_q, uart_qv);

reg [15:0] uart_dbg;
reg uart_dbg_v;
uart_rx_dbg i_uart_dbg(clk50, nrst, ch340_rx, uart_dbg, uart_dbg_v);

// assign ch340_tx = ch340_rx;
localparam DATA_BUF_LG2 = 2;
reg [7:0] ch340_data_buf [(1<<DATA_BUF_LG2) - 1:0];
reg [7:0] ch340_data;
reg [DATA_BUF_LG2-1:0] ch340_data_h;
reg [DATA_BUF_LG2-1:0] ch340_data_t;
reg ch340_data_valid;
reg ch340_data_ready;
uart_tx i_uart_tx(clk50, nrst, ch340_data, ch340_data_valid, ch340_data_ready, ch340_tx);

always @(posedge clk50) begin
	if (!nrst) begin
		ch340_data_buf <= '{default:0};
		ch340_data <= 0;
		ch340_data_h <= 0;
		ch340_data_t <= 0;
		ch340_data_valid <= 0;
	end else begin
		if (uart_qv) begin
			ch340_data_buf[ch340_data_t] <= uart_q;
			ch340_data_t <= ch340_data_t + 1;
			ch340_data_valid <= 1;
		end
		if (ch340_data_h != ch340_data_t) begin
			ch340_data <= ch340_data_buf[ch340_data_h];
			ch340_data_valid <= 1;
		end
		if (ch340_data_valid && ch340_data_ready) begin
			ch340_data_h <= ch340_data_h + 1;
			ch340_data_valid <= 0;
		end
	end
end

// assign led_segments = '1;
// assign led_enable = '1;
reg [3:0] led_data [7:0];
led i_led(clk50, nrst, led_data, led_segments, led_enable);

//always @(posedge clk50) begin
//	if (!nrst) begin
//		led_data <= '{default:0};
//	end else if (uart_qv) begin
//		led_data[0] <= uart_q[3:0];
//		led_data[1] <= uart_q[7:4];
//		for (int i = 2; i < 8; i++) begin
//			led_data[i] <= led_data[i-2];
//		end
//	end
//end

always @(posedge clk50) begin
	if (!nrst) begin
		led_data <= '{default:0};
	end else if (uart_dbg_v) begin
		led_data[0] <= uart_dbg[3:0];
		led_data[1] <= uart_dbg[7:4];
		led_data[2] <= uart_dbg[11:8];
		led_data[3] <= uart_dbg[15:12];
		for (int i = 4; i < 8; i++) begin
			led_data[i] <= led_data[i-4];
		end
	end
end

endmodule // ac4e6_board