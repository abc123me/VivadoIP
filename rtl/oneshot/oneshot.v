`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/04/2026 01:08:22 AM
// Design Name:    Data
// Module Name:    oneshot
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Simple block to assert a signal on another signal
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module oneshot # (
		input  wire trigger,
		input  wire reset,
		output reg  oneshot
	);

	wire signal;
	assign signal = reset || trigger;

	always @(posedge signal) begin
		if (trigger) begin
			oneshot <= 1;
		end
		if (reset) begin
			oneshot <= 0;
		end
	end
endmodule
