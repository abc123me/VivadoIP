# Vivado IP ![Gitea badge](http://192.168.1.10:30008/jeremiah/VivadoIP/actions/workflows/test-rtl.yml/badge.svg)

This is a collection of my vivado IP

Use at your own risk

## Interfaces

 - Pixel stream interface
   - A pixel stream master outputs pixel\_data, core\_clock, core\_clock\_en and inputs pixel\_ready and pixel\_sync signals
   - A pixel stream is a two-way mechanism used to obtain pixel data for a display driver
   - The display clock shall only be present when when core\_clock\_enable is high
   - The pixel\_sync shall be asserted on the negative pixel clock edge once the display isready for the first pixel
   - The pixel\_data shall be asserted prior to the positive edge of the pixel\_clock
 - One way SPI / TFT-SPI
   - A one-way SPI interface for TFT displays
   - Requires SDA, SCL, CS, and DC lines
   - Has optional reset and backlight controls

## RTL

Name                       | Description
---------------------------|--------------------------------------------------------------------------------------------------
`axi_fifo_sequencer`       | Meant to be used with `axi_pixel_fifo.v`, this IP block sequences writes to a singular AXI stream into multiple pixel FIFOs
`axi_pixel_fifo`           | Converts an AXI4 stream into a pixel stream, meanwhile buffering exactly one line of pixels
`bit_reverser`             | Swaps the bit order in each word (ie. MSB becomes LSB). This was done since I screwed up my board design.
`discrete_clock_converter` | IP block for moving a variable width discrete IO line from one clock domain to another clock domain
`oneshot`                  | Pretty much an SR-Latch, also comes with a free side of critical timing warnings / violations
`gpio74hc595`              | Converts a verilog logic vector input into GPIOs driven via a shift-register based GPIO expander
`tft_ili9341`              | Set of verilog files for driving the ILI9341 display, the core of the IP is located at `tft_ili9341_wrapper.v`

## Unit testing

Unit testing is done using `verilator` and `act`, I only run automated tests on my local git infrastructure and do not use GitHub actions

You can test yourself by running the following:
```
sudo pacman -S verilator act
./test
```
