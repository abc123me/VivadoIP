`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/04/2026 01:08:22 AM
// Design Name:    Data
// Module Name:    mux8
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Simple multiplexer block
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module mux8 # (
		parameter DATA_WIDTH = 16
	) (
		input  wire [DATA_WIDTH-1:0] inp0,
		input  wire [DATA_WIDTH-1:0] inp1,
		input  wire [DATA_WIDTH-1:0] inp2,
		input  wire [DATA_WIDTH-1:0] inp3,
		input  wire [DATA_WIDTH-1:0] inp4,
		input  wire [DATA_WIDTH-1:0] inp5,
		input  wire [DATA_WIDTH-1:0] inp6,
		input  wire [DATA_WIDTH-1:0] inp7,
		input  wire [3:0]            sel,
		output wire [DATA_WIDTH-1:0] outp
	);
	
	wire [DATA_WIDTH-1:0] inps [7:0];
	assign inps[0] = inp0;
	assign inps[1] = inp1;
	assign inps[2] = inp2;
	assign inps[3] = inp3;
	assign inps[4] = inp4;
	assign inps[5] = inp5;
	assign inps[6] = inp6;
	assign inps[7] = inp7;

	assign outp = inps[sel];
endmodule
