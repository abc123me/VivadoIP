`timescale 100ns / 10ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    04/05/2026 12:52:58 PM
// Design Name:    Shift register GPIO driver
// Module Name:    gpio74hc595
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    Takes input GPIOs and updates a shift register with them
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////


module gpio74hc595 # (
	    parameter REGISTER_COUNT = 1
    ) (
        // GPIO and clock inputs
        input  wire [(REGISTER_COUNT*8)-1:0] gpios,
        input  wire clock,
        input  wire resetn,
        
        // 74HC595 output lines
        (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF driver, ASSOCIATED_RESET driver_resetn, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0" *) output wire driver_clock,
        output reg  driver_resetn,
        output reg  driver_latch,
        output wire driver_data
    );
    
    localparam OUTPUT_BITS = REGISTER_COUNT * 8;
    localparam LAST_BIT    = OUTPUT_BITS - 1;
    
    // Clock & Reset control
    reg clock_enable;
    initial clock_enable = 0;
    assign driver_clock = clock & clock_enable;
    initial driver_resetn = 0;
    initial driver_latch = 0;

    // Internal data buffer
    reg [LAST_BIT:0] outputs;
    reg [$clog2(OUTPUT_BITS)-1:0] current_bit;
    initial current_bit = 0;
    assign driver_data = resetn ? outputs[current_bit] : 0;

    // Internal state machine
    reg [1:0] state;
    localparam STATE_START_DATA = 2'b00;
    localparam STATE_WRITE_DATA = 2'b01;
    localparam STATE_LATCH_DATA = 2'b10;
    initial state = STATE_START_DATA;
    always @(negedge clock) begin
        case (state)
            STATE_START_DATA: begin
                current_bit   <= 0;
                clock_enable  <= 1;
                driver_resetn <= 1;
                driver_latch  <= 0;
                outputs       <= gpios;
                state <= STATE_WRITE_DATA;
            end
            STATE_WRITE_DATA: begin
                current_bit <= current_bit + 1;
                if (current_bit >= LAST_BIT) begin
                    clock_enable <= 0;
                    state <= STATE_LATCH_DATA;
                end
            end
            STATE_LATCH_DATA: begin
                driver_latch <= 1;
                state <= STATE_START_DATA;
            end
        endcase
    end
endmodule
