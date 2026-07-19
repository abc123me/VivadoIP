`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/02/2026 12:39:17 AM
// Design Name:    Data
// Module Name:    tft_ili9341_init
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Initialization data for the ILI9341 display
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module tft_ili9341_init (
		input  wire       resetn,
		input  wire       clock,
		input  wire       clock_enable,
		output wire       done,
		output wire [8:0] data
	);

	// Init Sequence Data (based upon https://github.com/torvalds/linux/blob/master/drivers/staging/fbtft/fb_ili9341.c)
	// Another useful doc: https://github.com/adafruit/Adafruit_ILI9341/blob/master/Adafruit_ILI9341.cpp
	localparam INIT_SEQ_LEN = 53;
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
		INIT_SEQ[34] = {1'b0, 8'h3A}; INIT_SEQ[35] = {1'b1, 8'h55}; // 16 bit, 5-6-5 pixel format
		INIT_SEQ[36] = {1'b0, 8'h36}; INIT_SEQ[37] = {1'b1, 8'h48}; // Flip RGB
		// Frame Rate
		INIT_SEQ[38] = {1'b0, 8'hB1}; INIT_SEQ[39] = {1'b1, 8'h00}; INIT_SEQ[40] = {1'b1, 8'h1B}; // 70 FPS
		// Gamma
		INIT_SEQ[41] = {1'b0, 8'h26}; INIT_SEQ[42] = {1'b1, 8'h01};
		// Brightness
		INIT_SEQ[43] = {1'b0, 8'h51}; INIT_SEQ[44] = {1'b1, 8'hFF};
		// Display
		INIT_SEQ[45] = {1'b0, 8'hB7}; INIT_SEQ[46] = {1'b1, 8'h07};
		INIT_SEQ[47] = {1'b0, 8'hB6}; INIT_SEQ[48] = {1'b1, 8'h0A}; INIT_SEQ[49] = {1'b1, 8'h82}; INIT_SEQ[50] = {1'b1, 8'h27}; INIT_SEQ[51] = {1'b1, 8'h00};
		INIT_SEQ[52] = {1'b0, 8'h29}; // Enable Display
	end

	reg [$clog2(INIT_SEQ_LEN)-1:0] counter;
	initial counter = 0;
	assign data = INIT_SEQ[counter];
	assign done = counter >= INIT_SEQ_LEN;

	always @(posedge clock) begin
		if (resetn) begin
			if(clock_enable) begin
				if (!done) begin
					counter <= counter + 1;
				end
			end
		end else begin
			counter <= 0;
		end
	end
endmodule
