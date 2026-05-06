`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/04/2026 01:08:22 AM
// Design Name:    Data
// Module Name:    mux16
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Simple multiplexer block
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module mux16 # (
		parameter DATA_WIDTH = 16
	) (
		input  wire [DATA_WIDTH-1:0] inp00,
		input  wire [DATA_WIDTH-1:0] inp01,
		input  wire [DATA_WIDTH-1:0] inp02,
		input  wire [DATA_WIDTH-1:0] inp03,
		input  wire [DATA_WIDTH-1:0] inp04,
		input  wire [DATA_WIDTH-1:0] inp05,
		input  wire [DATA_WIDTH-1:0] inp06,
		input  wire [DATA_WIDTH-1:0] inp07,
		input  wire [DATA_WIDTH-1:0] inp08,
		input  wire [DATA_WIDTH-1:0] inp09,
		input  wire [DATA_WIDTH-1:0] inp10,
		input  wire [DATA_WIDTH-1:0] inp11,
		input  wire [DATA_WIDTH-1:0] inp12,
		input  wire [DATA_WIDTH-1:0] inp13,
		input  wire [DATA_WIDTH-1:0] inp14,
		input  wire [DATA_WIDTH-1:0] inp15,
		input  wire [3:0]            sel,
		output wire [DATA_WIDTH-1:0] outp
	);
	
	wire [DATA_WIDTH-1:0] inps [15:0];
	assign inps[0]  = inp0;
	assign inps[1]  = inp1;
	assign inps[2]  = inp2;
	assign inps[3]  = inp3;
	assign inps[4]  = inp4;
	assign inps[5]  = inp5;
	assign inps[6]  = inp6;
	assign inps[7]  = inp7;
	assign inps[8]  = inp8;
	assign inps[9]  = inp9;
	assign inps[10] = inp10;
	assign inps[11] = inp11;
	assign inps[12] = inp12;
	assign inps[13] = inp13;
	assign inps[14] = inp14;
	assign inps[15] = inp15;

	assign outp = inps[sel];
endmodule
