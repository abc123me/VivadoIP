`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/02/2026 12:39:17 AM
// Design Name:    Data
// Module Name:    tft_ili9341
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    ILI9341 TFT LCD display driver
// Dependencies:   tft_ili9341_spi.v, tft_ili9341_init.v, bit_reverser.v
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module tft_ili9341 # (
		parameter INPUT_CLK_MHZ = 50
	) (
		input clk,
		output wire tft_sck,
		output wire tft_sdi,
		output wire tft_dc,
		output reg  tft_reset,
		output wire tft_cs,
		input[15:0] pixel_data,
		output reg  pixel_ready
	);

	// Delay constants
	localparam DELAY_RESET = INPUT_CLK_MHZ * 10000;  // min: 10us  (changed to 10ms due to shift register delay)
	localparam DELAY_POWER = INPUT_CLK_MHZ * 200000; // min: 120ms (changed to 200ms due to shift register delay)
	localparam DELAY_INIT  = INPUT_CLK_MHZ * 5000;   // min: 5ms
	localparam DELAY_READY = INPUT_CLK_MHZ * 10000;  // min: 10ms
	localparam DELAY_PIXEL = 1;                      // probably not required, but I give the pixel data a clock cycle to settle

	// Assign pins and modules
	reg [15:0] pixel;
	reg [8:0]  spi_data;
	reg        spi_send;
	wire       spi_idle;

	// Initial assignments
	initial tft_reset = 1'b1;
	initial pixel_ready = 1'b0;
	initial spi_send = 1'b0;

	tft_ili9341_spi spi(
		.clk(clk), 
		.data(spi_data),
		.send(spi_send),
		.tft_sck(tft_sck),
		.tft_sdi(tft_sdi),
		.tft_dc(tft_dc),
		.tft_cs(tft_cs),
		.idle(spi_idle));

	reg init_clock;
	wire [8:0] init_data;
	wire init_done;
	tft_ili9341_init init(
		.clock(init_clock),
		.reset(0),
		.data(init_data),
		.done(init_done));

	initial init_clock = 1'b0;

	// state machine with delay + idle support (used for initialization)
	reg[23:0] delay_counter;
	initial delay_counter = 24'b0;

	// State machine for managing state
	localparam STATE_START              = 3'b000;
	localparam STATE_HOLD_RESET         = 3'b001;
	localparam STATE_WAIT_FOR_POWERUP   = 3'b010;
	localparam STATE_SEND_INIT_SEQ      = 3'b011;
	localparam STATE_ASSERT_PIXEL_READY = 3'b100;
	localparam STATE_STORE_PIXEL_DATA   = 3'b101;
	localparam STATE_SEND_UPPER_NIBBLE  = 3'b110;
	localparam STATE_SEND_LOWER_NIBBLE  = 3'b111;
	reg [2:0] state;
	initial state = STATE_START;

	always @ (posedge clk) begin
		// clear data flag first
		spi_send <= 1'b0;

		// always decrement delay ticks
		if (delay_counter > 0) begin
			delay_counter <= delay_counter - 1'b1;
		end else if (spi_idle && !spi_send) begin
			// advance state machine to next state, but only do this if we
			// didn't just clock in the last byte (since idle is not yet updated)
			case (state)
				// initialize all pins in START mode; reset the LCD
				STATE_START: begin
					tft_reset <= 1'b0;
					delay_counter <= DELAY_RESET;
					state <= STATE_HOLD_RESET;
				end

				// wait for RESET to kick in; then release pin & wait for power up
				STATE_HOLD_RESET: begin
					tft_reset <= 1'b1; // release pin
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
						state <= STATE_ASSERT_PIXEL_READY;
						delay_counter <= DELAY_READY;
					end else begin
						if(!init_clock) begin
							spi_data <= init_data;
							spi_send <= 1'b1;
						end
						init_clock <= !init_clock;
					end
				end

				// frame buffer loop
				STATE_ASSERT_PIXEL_READY: begin
					delay_counter <= DELAY_PIXEL;
					state <= STATE_STORE_PIXEL_DATA;
					pixel_ready <= 1;
				end

				STATE_STORE_PIXEL_DATA: begin
					pixel <= pixel_data;
					state <= STATE_SEND_UPPER_NIBBLE;
					pixel_ready <= 0;
				end

				STATE_SEND_UPPER_NIBBLE: begin
					spi_data <= {1'b1, pixel[15:8]};
					spi_send <= 1'b1;
					state <= STATE_SEND_LOWER_NIBBLE;
				end

				STATE_SEND_LOWER_NIBBLE: begin
					spi_data <= {1'b1, pixel[7:0]};
					spi_send <= 1'b1;
					state <= STATE_ASSERT_PIXEL_READY;
				end
			endcase
		end
	end
endmodule
