`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/02/2026 12:39:17 AM
// Design Name:    Data
// Module Name:    tft_ili9341_spi
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    The one way, three wire, nine bit SPI driver for the ILI9341
// Dependencies:   bit_reverser.v
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module tft_ili9341_spi(
		input  wire clk,
		input  wire [8:0] data,
		input  wire send,
		output wire tft_sck,
		output reg tft_sdi,
		output reg tft_dc,
		output wire tft_cs,
		output reg idle
	);

	// Registers
	reg[2:0] counter;
	reg[8:0] idata;
	reg sck;
	reg cs;

	initial sck = 1'b1;
	initial counter = 3'b0;
	initial idle = 1'b1;
	initial cs = 1'b0;

	// Combinational Assignments
	wire dc;
	wire[7:0] rdata;
	bit_reverser # (.WORD_COUNT(1)) rev (.inp(idata[7:0]), .outp(rdata));
	assign dc = idata[8];
	assign tft_sck = sck & cs; // only drive sck with an active CS
	assign tft_cs = !cs; // active low

	// Update SPI CLK + Output data
	always @ (posedge clk) begin
		// Store new data in internal register
		if (send) begin
			idata <= data;
			idle <= 1'b0;
		end

		// Change data if we're actively sending
		if (!idle) begin
			// Toggle Clock on every active tick
			sck <= !sck;

			// Check if SCK will be low next
			if (sck) begin
				// Update pins
				tft_dc <= dc;
				tft_sdi <= rdata[counter];
				cs <= 1'b1;

				// Advance counter
				counter <= counter + 1'b1;
				idle <= &counter; // we're just sending the last bit
			end
		end else begin
			sck <= 1'b1; // idle mode (also: sent last bit)
			if (sck) begin
				cs <= 1'b0; // idle for two bits in a row -> deactivate CS
			end
		end
	end	
endmodule
