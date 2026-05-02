/** Simple frame-buffer based driver for the ILI9341 TFT module */
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
		.spiClk(clk), 
		.data(spi_data),
		.dataAvailable(spi_send),
		.tft_sck(tft_sck),
		.tft_sdi(tft_sdi),
		.tft_dc(tft_dc),
		.tft_cs(tft_cs),
		.idle(spi_idle));

	// Init Sequence Data (based upon https://github.com/notro/fbtft/blob/master/fb_ili9341.c)
	localparam INIT_SEQ_LEN = 52;
	reg[5:0]  init_counter = 6'b0;
	reg [8:0] INIT_SEQ [0:INIT_SEQ_LEN-1];

	initial begin
		// Turn off Display
		INIT_SEQ[0]  = {1'b0, 8'h28};
		// Init (??)
		INIT_SEQ[1]  = {1'b0, 8'hCF}; INIT_SEQ[2]  = {1'b1, 8'h00}; INIT_SEQ[3]  = {1'b1, 8'h83}; INIT_SEQ[4]  = {1'b1, 8'h30};
		INIT_SEQ[5]  = {1'b0, 8'hED}; INIT_SEQ[6]  = {1'b1, 8'h64}; INIT_SEQ[7]  = {1'b1, 8'h03}; INIT_SEQ[8]  = {1'b1, 8'h12}; INIT_SEQ[9]  = {1'b1, 8'h81};
		INIT_SEQ[10] = {1'b0, 8'hE8}; INIT_SEQ[11] = {1'b1, 8'h85}; INIT_SEQ[12] = {1'b1, 8'h01}; INIT_SEQ[13] = {1'b1, 8'h79};
		INIT_SEQ[14] = {1'b0, 8'hCB}; INIT_SEQ[15] = {1'b1, 8'h39}; INIT_SEQ[16] = {1'b1, 8'h2C}; INIT_SEQ[17] = {1'b1, 8'h00}; INIT_SEQ[18] = {1'b1, 8'h34}; INIT_SEQ[19] = {1'b1, 8'h02};
		INIT_SEQ[20] = {1'b0, 8'hF7}; INIT_SEQ[21] = {1'b1, 8'h20};
		INIT_SEQ[22] = {1'b0, 8'hEA}; INIT_SEQ[23] = {1'b1, 8'h00}; INIT_SEQ[24] = {1'b1, 8'h00};
		// Power Control
		INIT_SEQ[25] = {1'b0, 8'hC0}; INIT_SEQ[26] = {1'b1, 8'h26};
		INIT_SEQ[27] = {1'b0, 8'hC1}; INIT_SEQ[28] = {1'b1, 8'h11};
		// VCOM
		INIT_SEQ[29] = {1'b0, 8'hC5}; INIT_SEQ[30] = {1'b1, 8'h35}; INIT_SEQ[31] = {1'b1, 8'h3E};
		INIT_SEQ[32] = {1'b0, 8'hC7}; INIT_SEQ[33] = {1'b1, 8'hBE};
		// Memory Access Control
		INIT_SEQ[34] = {1'b0, 8'h3A}; INIT_SEQ[35] = {1'b1, 8'h55};
		// Frame Rate
		INIT_SEQ[36] = {1'b0, 8'hB1}; INIT_SEQ[37] = {1'b1, 8'h00}; INIT_SEQ[38] = {1'b1, 8'h1B};
		// Gamma
		INIT_SEQ[39] = {1'b0, 8'h26}; INIT_SEQ[40] = {1'b1, 8'h01};
		// Brightness
		INIT_SEQ[41] = {1'b0, 8'h51}; INIT_SEQ[42] = {1'b1, 8'hFF};
		// Display
		INIT_SEQ[43] = {1'b0, 8'hB7}; INIT_SEQ[44] = {1'b1, 8'h07};
		INIT_SEQ[45] = {1'b0, 8'hB6}; INIT_SEQ[46] = {1'b1, 8'h0A}; INIT_SEQ[47] = {1'b1, 8'h82}; INIT_SEQ[48] = {1'b1, 8'h27}; INIT_SEQ[49] = {1'b1, 8'h00};
		INIT_SEQ[50] = {1'b0, 8'h29}; // Enable Display
		INIT_SEQ[51] = {1'b0, 8'h2C}; // Start Memory-Write
	end

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
					if (init_counter < INIT_SEQ_LEN) begin
						spi_data <= INIT_SEQ[init_counter];
						spi_send <= 1'b1;
						init_counter <= init_counter + 1'b1;
					end else begin
						state <= STATE_ASSERT_PIXEL_READY;
						delay_counter <= DELAY_READY;
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
