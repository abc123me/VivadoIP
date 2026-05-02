`timescale 10ns / 1ns
// --- Byte-wise SPI + DC implementation
// * Will copy data into internal buffer
// * 'Idle' will be set to 0 once buffer copy is complete
// * Data is only copied if 'dataAvailable' is set to 1
// * SPI CLK will stop (high state) if no data is being sent
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
	reg internalSck;
	reg cs;
	
	initial internalSck = 1'b1;
	initial counter = 3'b0;
	initial idle = 1'b1;
	initial cs = 1'b0;
	
	// Combinational Assignments
	wire dc;
	wire[7:0] rdata;
	assign rdata[7] = idata[0];
	assign rdata[6] = idata[1];
	assign rdata[5] = idata[2];
	assign rdata[4] = idata[3];
	assign rdata[3] = idata[4];
	assign rdata[2] = idata[5];
	assign rdata[1] = idata[6];
	assign rdata[0] = idata[7];
	assign dc = idata[8];
	
	assign tft_sck = internalSck & cs; // only drive sck with an active CS
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
			internalSck <= !internalSck;
				
			// Check if SCK will be low next
			if (internalSck) begin
				// Update pins
				tft_dc <= dc;
				tft_sdi <= rdata[counter];
				cs <= 1'b1;
				
				// Advance counter
				counter <= counter + 1'b1;
				idle <= &counter; // we're just sending the last bit
			end
		end
		else begin
			internalSck <= 1'b1; // idle mode (also: sent last bit)
			if (internalSck) cs <= 1'b0; // idle for two bits in a row -> deactivate CS
		end
	end	
endmodule
