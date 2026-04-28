# Vivado IP

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
