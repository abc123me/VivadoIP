`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    05/02/2026 12:39:17 AM
// Design Name:    Data
// Module Name:    tft_ili9341_wrapper
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Vivado wrapper block for the ILI9341
// Dependencies:   tft_ili9341.v, tft_ili9341_spi.v, tft_ili9341_init.v, bit_reverser.v
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////

module tft_ili9341_wrapper # (
		parameter INPUT_CLK_MHZ = 50,
		parameter WIDTH  = 320,
		parameter HEIGHT = 240,
		parameter PIXEL_WIDTH = 16
	) (
		// Display data out
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi scl" *)  output wire tft_sck,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi sda" *)  output wire tft_sda,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi dc" *)   output wire tft_dc,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi nrst" *) output wire tft_nrst,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi cs" *)   output wire tft_cs,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:tftspi:1.0 m_tftspi led" *)  output reg  tft_led,

		// Pixel stream in
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_data" *)    input  wire [PIXEL_WIDTH-1:0] pixel_data,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream core_clock" *)    input  wire core_clock,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream core_clock_en" *) input  wire core_clock_en,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_ready" *)   output wire pixel_ready,
		(* X_INTERFACE_INFO = "kn4hji.ddns.net:interface:pixel_stream:1.0 s_pixel_stream pixel_sync" *)    output reg  pixel_sync,
		
		// Miscellaneous
		input  wire io_ready,
		output wire io_wait,
		input  wire aresetn,
		output wire ready
	);

	localparam LAST_PIXEL = WIDTH * HEIGHT - 1;

	// Backlight is turned on after first frame is drawn
	initial tft_led = 0;

	// Counter for outputting a pixel sync bit
	reg [$clog2(LAST_PIXEL):0] pixel_counter;
	initial pixel_counter = 0;

	// The "pixel sync" is high whenever on the 0th pixel
	// this allows external IP to know when it can begin
	// providing pixel data to the IP block
	initial pixel_sync = 1;

	reg pixel_ready_oneshot;
	initial pixel_ready_oneshot = 0;
	always @(negedge core_clock) begin
		if (pixel_ready) begin
			pixel_ready_oneshot <= 1;
		end else if(pixel_ready_oneshot) begin
			if (pixel_counter < LAST_PIXEL) begin
				pixel_sync <= 0;
				pixel_counter <= pixel_counter + 1'b1;
			end else begin
				pixel_sync <= 1;
				pixel_counter <= 0;
				tft_led <= 1;
			end
			pixel_ready_oneshot <= 0;
		end
	end

	// ILI9341 driver IP, thanks to "thekroko" for making this!
	// https://github.com/thekroko/ili9341_fpga/tree/master
	tft_ili9341 # (
		.INPUT_CLK_MHZ(INPUT_CLK_MHZ)
	) tft (
		.clock(core_clock),
		.clock_enable(core_clock_en),
		.tft_sck(tft_sck),
		.tft_sdi(tft_sda),
		.tft_dc(tft_dc),
		.tft_reset(tft_nrst),
		.tft_cs(tft_cs),
		.pixel_data(pixel_data),
		.pixel_ready(pixel_ready),
		.pixel_sync(pixel_sync),
		.io_ready(io_ready),
		.io_wait(io_wait),
		.driver_resetn(aresetn),
		.driver_ready(ready)
	);
endmodule
