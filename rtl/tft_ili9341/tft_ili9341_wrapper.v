`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/02/2026 12:39:17 AM
// Design Name:    Data
// Module Name:    tft_ili9341_wrapper
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    ILI9341 TFT LCD display driver
// Dependencies:   tft_ili9341_spi.v, tft_ili9341_init.v, bit_reverser.v
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module tft_ili9341_wrapper # (
		parameter INPUT_CLK_MHZ = 50,
		parameter PIXEL_WIDTH = 16,
		parameter WIDTH  = 320,
		parameter HEIGHT = 240
	) (
		// Display data out
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi scl" *)  output wire tft_sck,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi sda" *)  output wire tft_sda,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi dc" *)   output wire tft_dc,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi nrst" *) output reg  tft_nrst,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi cs" *)   output wire tft_cs,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi led" *)  output reg  tft_led,

		// Pixel stream in
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_data" *)    input  wire [PIXEL_WIDTH-1:0] pixel_data,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream core_clock" *)    input  wire core_clock,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream core_clock_en" *) input  wire core_clock_en,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_ready" *)   output reg  pixel_ready,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_sync" *)    output reg  pixel_sync
	);

	// The constants
	localparam LAST_PIXEL  = WIDTH * HEIGHT - 1;
	localparam DELAY_RESET = INPUT_CLK_MHZ * 10000;  // min: 10us  (changed to 10ms due to shift register delay)
	localparam DELAY_POWER = INPUT_CLK_MHZ * 200000; // min: 120ms (changed to 200ms due to shift register delay)
	localparam DELAY_INIT  = INPUT_CLK_MHZ * 5000;   // min: 5ms
	localparam DELAY_READY = INPUT_CLK_MHZ * 10000;  // min: 10ms
	localparam DELAY_PIXEL = 1;                      // probably not required, but I give the pixel data a clock cycle to settle

	// ====================================================
	//                    SPI Driver
	// ====================================================

	reg [8:0]  spi_data;
	reg        spi_send;
	wire       spi_idle;

	initial spi_data = 9'b0;
	initial spi_send = 1'b0;

	tft_ili9341_spi spi(
		.clk(core_clock),
		.data(spi_data),
		.send(spi_send),
		.tft_sck(tft_sck),
		.tft_sdi(tft_sda),
		.tft_dc(tft_dc),
		.tft_cs(tft_cs),
		.idle(spi_idle));

	// ====================================================
	//             Initialization sequence
	// ====================================================

	wire [8:0] init_data;
	wire init_done;
	reg init_enable;

	initial init_enable = 1'b0;

	tft_ili9341_init init(
		.clock(core_clock),
		.enable(init_enable),
		.reset(0),
		.data(init_data),
		.done(init_done));

	// ====================================================
	//                 TFT Driver outputs
	// ====================================================

	initial tft_nrst = 1'b1;
	initial tft_led  = 1'b0;

	// ====================================================
	//                Display driver state
	// ====================================================

	reg [15:0] pixel;
	// Counter for outputting a pixel sync bit
	reg [$clog2(LAST_PIXEL):0] pixel_counter;
	reg pixel_ready_oneshot;

	// state machine with delay + idle support (used for initialization)
	reg[23:0] delay_counter;

	// State machine for managing state
	localparam STATE_START              = 4'b0000;
	localparam STATE_HOLD_RESET         = 4'b0001;
	localparam STATE_WAIT_FOR_POWERUP   = 4'b0010;
	localparam STATE_SEND_INIT_SEQ      = 4'b0011;
	localparam STATE_ASSERT_PIXEL_READY = 4'b0100;
	localparam STATE_STORE_PIXEL_DATA   = 4'b0101;
	localparam STATE_SEND_UPPER_NIBBLE  = 4'b0110;
	localparam STATE_SEND_LOWER_NIBBLE  = 4'b0111;
	localparam STATE_START_MEMORY_WRITE = 4'b1000;
	reg [3:0] state;

	// Initial values
	initial delay_counter = 24'b0;
	initial pixel_ready_oneshot = 0;
	initial pixel_counter = 0;
	initial pixel_sync = 0;
	initial pixel_ready = 0;
	initial state = STATE_START;

	always @ (posedge core_clock) begin
		// clear data flag first
		spi_send <= 1'b0;
		if (init_enable) begin
			init_enable <= 1'b0;
		end

		// always decrement delay ticks
		if (delay_counter > 0) begin
			delay_counter <= delay_counter - 1'b1;
		end else if (spi_idle && !spi_send && core_clock_en) begin
			// advance state machine to next state, but only do this if we
			// didn't just clock in the last byte (since idle is not yet updated)
			case (state)
				// initialize all pins in START mode; reset the LCD
				STATE_START: begin
					tft_nrst <= 1'b0;
					delay_counter <= DELAY_RESET;
					state <= STATE_HOLD_RESET;
				end

				// wait for RESET to kick in; then release pin & wait for power up
				STATE_HOLD_RESET: begin
					tft_nrst <= 1'b1; // release pin
					delay_counter <= DELAY_POWER;
					state <= STATE_WAIT_FOR_POWERUP;
				end

				// if power up is completed -> sw reset
				STATE_WAIT_FOR_POWERUP: begin
					spi_data <= {1'b0, 8'h11}; // take out of sleep mode
					spi_send <= 1'b1;
					delay_counter <= DELAY_INIT;
					state <= STATE_SEND_INIT_SEQ;
				end

				// setup the LCD by sending the init sequence
				STATE_SEND_INIT_SEQ: begin
					if (init_done) begin
						state <= STATE_START_MEMORY_WRITE;
						delay_counter <= DELAY_READY;
					end else begin
						init_enable <= 1'b1;
						spi_data <= init_data;
						spi_send <= 1'b1;
					end
				end

				// frame buffer loop
				STATE_START_MEMORY_WRITE: begin
					spi_data <= {1'b0, 8'h2C};
					spi_send <= 1'b1;
					pixel_sync <= 1;
					state <= STATE_ASSERT_PIXEL_READY;
                end

				STATE_ASSERT_PIXEL_READY: begin
					delay_counter <= DELAY_PIXEL;
					state <= STATE_STORE_PIXEL_DATA;
				    pixel_counter <= pixel_counter + 1'b1;
					pixel_ready <= 1;
				end

				STATE_STORE_PIXEL_DATA: begin
					pixel <= pixel_data;
					state <= STATE_SEND_UPPER_NIBBLE;
					pixel_ready <= 0;
					pixel_sync  <= 0;
				end

				STATE_SEND_UPPER_NIBBLE: begin
					spi_data <= {1'b1, pixel[15:8]};
					spi_send <= 1'b1;
					state <= STATE_SEND_LOWER_NIBBLE;
				end

				STATE_SEND_LOWER_NIBBLE: begin
					spi_data <= {1'b1, pixel[7:0]};
					spi_send <= 1'b1;
					if (pixel_counter >= LAST_PIXEL) begin
						state <= STATE_START_MEMORY_WRITE;
						pixel_counter <= 0;
						tft_led <= 1;
					end else begin
						state <= STATE_ASSERT_PIXEL_READY;
					end
				end
			endcase
		end
	end
endmodule
