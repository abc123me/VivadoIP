`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    04/05/2026 12:52:58 PM
// Design Name:    Data
// Module Name:    bit_reverser
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Flips endianess, ie. MSB..LSB becomes LSB..MSB
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module bit_reverser # (
	parameter WORD_SIZE  = 8,
	parameter WORD_COUNT = 2
) (
	input  wire [(WORD_SIZE * WORD_COUNT)-1:0] inp,
	output wire [(WORD_SIZE * WORD_COUNT)-1:0] outp
);
	genvar w, b;
	generate
		for (w = 0; w < WORD_COUNT; w = w + 1) begin : word_loop
			for (b = 0; b < WORD_SIZE; b = b + 1) begin : bit_loop
				assign outp[(w * WORD_SIZE) + b] = inp[(w * WORD_SIZE) + (WORD_SIZE - 1 - b)];
			end
		end
	endgenerate
endmodule
