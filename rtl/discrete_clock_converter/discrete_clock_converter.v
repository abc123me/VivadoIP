`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    07/23/2026 02:20:23 AM
// Design Name:    Discrete clock divider
// Module Name:    discrete_clock_divider
// Project Name:   Any
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Moves a discrete vector signal from one clock domain to another
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////


module discrete_clock_converter # (
	parameter DATA_WIDTH = 16,
	parameter RESET_VAL  = 0
) (
	input  wire inp_clock,
	input  wire inp_resetn,
	input  wire out_clock,
	input  wire out_resetn,
	input  wire [DATA_WIDTH-1:0] data_inp,
	output  reg [DATA_WIDTH-1:0] data_out
);

	reg [DATA_WIDTH-1:0] data_int;
	initial data_int = RESET_VAL;

	always @(posedge inp_clock) begin
		data_int <= inp_resetn ? data_inp : RESET_VAL;
	end

	always @(posedge out_clock) begin
		data_out <= out_resetn ? data_int : RESET_VAL;
	end
endmodule
