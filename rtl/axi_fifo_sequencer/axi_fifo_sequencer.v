`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    04/05/2026 12:52:58 PM
// Design Name:    AXI FIFO Sequencer
// Module Name:    axi_fifo_sequencer
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    An AXI FIFO sequencer for the AXI pixel FIFO
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////


module axi_fifo_sequencer # (
		parameter DATA_WIDTH   = 16,
		parameter MAX_DISPLAYS = 4,
		parameter LAST_DISPLAY = 3,
		parameter DISPLAY_COLS = 240,
		parameter DISPLAY_ROWS = 320
	) (
		// Miscellaneous signals
		input  wire axis_clock,
		input  wire axis_aresetn,

		// FIFO Controls
		output wire [MAX_DISPLAYS-1:0] read_enables,
		input  wire [MAX_DISPLAYS-1:0] read_completes,

		// AXI4 Streams out
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *)  output wire                  m00_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *) output wire                  m00_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m00_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *) input  wire                  m00_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS TLAST" *)  output wire                  m01_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS TVALID" *) output wire                  m01_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m01_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS TREADY" *) input  wire                  m01_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS TLAST" *)  output wire                  m02_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS TVALID" *) output wire                  m02_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m02_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS TREADY" *) input  wire                  m02_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS TLAST" *)  output wire                  m03_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS TVALID" *) output wire                  m03_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m03_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS TREADY" *) input  wire                  m03_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M04_AXIS TLAST" *)  output wire                  m04_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M04_AXIS TVALID" *) output wire                  m04_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M04_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m04_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M04_AXIS TREADY" *) input  wire                  m04_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M05_AXIS TLAST" *)  output wire                  m05_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M05_AXIS TVALID" *) output wire                  m05_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M05_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m05_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M05_AXIS TREADY" *) input  wire                  m05_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M06_AXIS TLAST" *)  output wire                  m06_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M06_AXIS TVALID" *) output wire                  m06_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M06_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m06_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M06_AXIS TREADY" *) input  wire                  m06_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M07_AXIS TLAST" *)  output wire                  m07_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M07_AXIS TVALID" *) output wire                  m07_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M07_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m07_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M07_AXIS TREADY" *) input  wire                  m07_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M08_AXIS TLAST" *)  output wire                  m08_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M08_AXIS TVALID" *) output wire                  m08_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M08_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m08_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M08_AXIS TREADY" *) input  wire                  m08_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M09_AXIS TLAST" *)  output wire                  m09_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M09_AXIS TVALID" *) output wire                  m09_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M09_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m09_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M09_AXIS TREADY" *) input  wire                  m09_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M10_AXIS TLAST" *)  output wire                  m10_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M10_AXIS TVALID" *) output wire                  m10_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M10_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m10_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M10_AXIS TREADY" *) input  wire                  m10_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M11_AXIS TLAST" *)  output wire                  m11_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M11_AXIS TVALID" *) output wire                  m11_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M11_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m11_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M11_AXIS TREADY" *) input  wire                  m11_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M12_AXIS TLAST" *)  output wire                  m12_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M12_AXIS TVALID" *) output wire                  m12_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M12_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m12_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M12_AXIS TREADY" *) input  wire                  m12_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M13_AXIS TLAST" *)  output wire                  m13_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M13_AXIS TVALID" *) output wire                  m13_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M13_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m13_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M13_AXIS TREADY" *) input  wire                  m13_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M14_AXIS TLAST" *)  output wire                  m14_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M14_AXIS TVALID" *) output wire                  m14_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M14_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m14_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M14_AXIS TREADY" *) input  wire                  m14_axis_tready,

		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M15_AXIS TLAST" *)  output wire                  m15_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M15_AXIS TVALID" *) output wire                  m15_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M15_AXIS TDATA" *)  output wire [DATA_WIDTH-1:0] m15_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M15_AXIS TREADY" *) input  wire                  m15_axis_tready,

		// AXI4 Stream in
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *)  input  wire s_axis_tlast,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input  wire s_axis_tvalid,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)  input  wire [DATA_WIDTH-1:0] s_axis_tdata,
		(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output wire s_axis_tready
	);

	reg [$clog2(MAX_DISPLAYS)-1:0] display;
	initial display = 0;

	reg [$clog2(DISPLAY_COLS)-1:0] col_counter;
	initial col_counter = 0;

	reg [$clog2(DISPLAY_ROWS)-1:0] row_counter;
	initial row_counter = 0;

	reg [15:0] tlasts;
	initial tlasts = 0;

	reg manual_resetn;
	initial manual_resetn = 0;

	wire resetn;
	assign resetn = manual_resetn && axis_aresetn;

	wire actual_tvalid;
	assign actual_tvalid = s_axis_tvalid && resetn;

	wire tlast_enable;
	assign tlast_enable = resetn;

	wire last_row;
	wire last_col;
	wire last_dat;
	assign last_row = row_counter >= (DISPLAY_ROWS - 1);
	assign last_col = col_counter >= (DISPLAY_COLS - 1);
	assign display_tlast = last_row && last_col;

	assign m00_axis_tdata  = s_axis_tdata;
	assign m00_axis_tvalid = actual_tvalid && display == 00;
	assign m00_axis_tlast  = tlast_enable  && (tlasts[00] || (display == 00 && display_tlast));

	assign m01_axis_tdata  = s_axis_tdata;
	assign m01_axis_tvalid = actual_tvalid && display == 01;
	assign m01_axis_tlast  = tlast_enable  && (tlasts[01] || (display == 01 && display_tlast));

	assign m02_axis_tdata  = s_axis_tdata;
	assign m02_axis_tvalid = actual_tvalid && display == 02;
	assign m02_axis_tlast  = tlast_enable  && (tlasts[02] || (display == 02 && display_tlast));

	assign m03_axis_tdata  = s_axis_tdata;
	assign m03_axis_tvalid = actual_tvalid && display == 03;
	assign m03_axis_tlast  = tlast_enable  && (tlasts[03] || (display == 03 && display_tlast));

	assign m04_axis_tdata  = s_axis_tdata;
	assign m04_axis_tvalid = actual_tvalid && display == 04;
	assign m04_axis_tlast  = tlast_enable  && (tlasts[04] || (display == 04 && display_tlast));

	assign m05_axis_tdata  = s_axis_tdata;
	assign m05_axis_tvalid = actual_tvalid && display == 05;
	assign m05_axis_tlast  = tlast_enable  && (tlasts[05] || (display == 05 && display_tlast));

	assign m06_axis_tdata  = s_axis_tdata;
	assign m06_axis_tvalid = actual_tvalid && display == 06;
	assign m06_axis_tlast  = tlast_enable  && (tlasts[06] || (display == 06 && display_tlast));

	assign m07_axis_tdata  = s_axis_tdata;
	assign m07_axis_tvalid = actual_tvalid && display == 07;
	assign m07_axis_tlast  = tlast_enable  && (tlasts[07] || (display == 07 && display_tlast));

	assign m08_axis_tdata  = s_axis_tdata;
	assign m08_axis_tvalid = actual_tvalid && display == 08;
	assign m08_axis_tlast  = tlast_enable  && (tlasts[08] || (display == 08 && display_tlast));

	assign m09_axis_tdata  = s_axis_tdata;
	assign m09_axis_tvalid = actual_tvalid && display == 09;
	assign m09_axis_tlast  = tlast_enable  && (tlasts[09] || (display == 09 && display_tlast));

	assign m10_axis_tdata  = s_axis_tdata;
	assign m10_axis_tvalid = actual_tvalid && display == 10;
	assign m10_axis_tlast  = tlast_enable  && (tlasts[10] || (display == 10 && display_tlast));

	assign m11_axis_tdata  = s_axis_tdata;
	assign m11_axis_tvalid = actual_tvalid && display == 11;
	assign m11_axis_tlast  = tlast_enable  && (tlasts[11] || (display == 11 && display_tlast));

	assign m12_axis_tdata  = s_axis_tdata;
	assign m12_axis_tvalid = actual_tvalid && display == 12;
	assign m12_axis_tlast  = tlast_enable  && (tlasts[12] || (display == 12 && display_tlast));

	assign m13_axis_tdata  = s_axis_tdata;
	assign m13_axis_tvalid = actual_tvalid && display == 13;
	assign m13_axis_tlast  = tlast_enable  && (tlasts[13] || (display == 13 && display_tlast));

	assign m14_axis_tdata  = s_axis_tdata;
	assign m14_axis_tvalid = actual_tvalid && display == 14;
	assign m14_axis_tlast  = tlast_enable  && (tlasts[14] || (display == 14 && display_tlast));

	assign m15_axis_tdata  = s_axis_tdata;
	assign m15_axis_tvalid = actual_tvalid && display == 15;
	assign m15_axis_tlast  = tlast_enable  && (tlasts[15] || (display == 15 && display_tlast));

	wire [15:0] treadies;
	assign treadies[0]  = m00_axis_tready;
	assign treadies[1]  = m01_axis_tready;
	assign treadies[2]  = m02_axis_tready;
	assign treadies[3]  = m03_axis_tready;
	assign treadies[4]  = m04_axis_tready;
	assign treadies[5]  = m05_axis_tready;
	assign treadies[6]  = m06_axis_tready;
	assign treadies[7]  = m07_axis_tready;
	assign treadies[8]  = m08_axis_tready;
	assign treadies[9]  = m09_axis_tready;
	assign treadies[10] = m10_axis_tready;
	assign treadies[11] = m11_axis_tready;
	assign treadies[12] = m12_axis_tready;
	assign treadies[13] = m13_axis_tready;
	assign treadies[14] = m14_axis_tready;
	assign treadies[15] = m15_axis_tready;

	reg [1:0] state;
	localparam STATE_SENDING_DATA  = 2'b00;
	localparam STATE_NEXT_DISPLAY  = 2'b01;
	localparam STATE_WAIT_COMPLETE = 2'b10;
	localparam STATE_WAIT_TVALID   = 2'b11;
	initial state = STATE_SENDING_DATA;

	assign s_axis_tready = treadies[display] && resetn && state == STATE_SENDING_DATA;
	assign read_enables  = (state == STATE_SENDING_DATA) ? (16'b1 << display) : 0;

	always @(posedge axis_clock) begin
		if (resetn) begin
			case (state)
				STATE_SENDING_DATA: begin
					if (s_axis_tvalid && s_axis_tready) begin
						tlasts[display] <= display_tlast;
						if (last_col) begin
							state <= STATE_NEXT_DISPLAY;
							col_counter <= 0;
						end else begin
							col_counter <= col_counter + 1;
						end
					end
				end
				STATE_NEXT_DISPLAY: begin
					state <= s_axis_tlast ? STATE_WAIT_COMPLETE : STATE_SENDING_DATA;
					if (display >= LAST_DISPLAY) begin
						row_counter <= row_counter + 1;
						display <= 0;
					end else begin
						display <= display + 1;
					end
				end
				STATE_WAIT_COMPLETE: begin
					if(!(|read_completes)) begin
						state <= STATE_WAIT_TVALID;
						display <= 0;
					end
				end
				STATE_WAIT_TVALID: begin
					if (!s_axis_tlast && s_axis_tvalid) begin
						manual_resetn <= 0;
					end
				end
			endcase
		end else begin
			manual_resetn <= 1;
			state <= STATE_SENDING_DATA;
			col_counter <= 0;
			row_counter <= 0;
			display <= 0;
			tlasts <= 0;
		end
	end
endmodule
