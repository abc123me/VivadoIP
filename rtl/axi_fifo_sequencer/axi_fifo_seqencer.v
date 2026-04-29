`timescale 10ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Lowe Contracting
// Engineer:       Jeremiah Lowe
// Create Date:    04/05/2026 12:52:58 PM
// Design Name:    AXI FIFO Sequencer
// Module Name:    axi_sequencer
// Project Name:   Screen Hat
// Target Devices: Any
// Tool Versions:  Vivado 2025.2 and above
// Description:    An AXI FIFO sequencer for the AXI pixel FIFO
// Dependencies:   None
// Revision:       1.0
//////////////////////////////////////////////////////////////////////////////////


module pixel_fifo_sequencer # (
		parameter DATA_WIDTH = 16,
		parameter OUTPUT_CNT = 4
	) (
		// Miscellaneous signals
		input  wire axis_clock,
		input  wire axis_aresetn,
		input  wire global_ready,

		// FIFO Controls
		output wire [OUTPUT_CNT-1:0] read_enables,
		input  wire [OUTPUT_CNT-1:0] write_completes,
		input  wire [OUTPUT_CNT-1:0] read_completes,

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

	assign m00_axis_tdata  = s_axis_tdata;
	assign m00_axis_tvalid = s_axis_tvalid;
	assign m00_axis_tlast  = s_axis_tlast;

	assign m01_axis_tdata  = s_axis_tdata;
	assign m01_axis_tvalid = s_axis_tvalid;
	assign m01_axis_tlast  = s_axis_tlast;

	assign m02_axis_tdata  = s_axis_tdata;
	assign m02_axis_tvalid = s_axis_tvalid;
	assign m02_axis_tlast  = s_axis_tlast;

	assign m03_axis_tdata  = s_axis_tdata;
	assign m03_axis_tvalid = s_axis_tvalid;
	assign m03_axis_tlast  = s_axis_tlast;

	assign m04_axis_tdata  = s_axis_tdata;
	assign m04_axis_tvalid = s_axis_tvalid;
	assign m04_axis_tlast  = s_axis_tlast;

	assign m05_axis_tdata  = s_axis_tdata;
	assign m05_axis_tvalid = s_axis_tvalid;
	assign m05_axis_tlast  = s_axis_tlast;

	assign m06_axis_tdata  = s_axis_tdata;
	assign m06_axis_tvalid = s_axis_tvalid;
	assign m06_axis_tlast  = s_axis_tlast;

	assign m07_axis_tdata  = s_axis_tdata;
	assign m07_axis_tvalid = s_axis_tvalid;
	assign m07_axis_tlast  = s_axis_tlast;

	assign m08_axis_tdata  = s_axis_tdata;
	assign m08_axis_tvalid = s_axis_tvalid;
	assign m08_axis_tlast  = s_axis_tlast;

	assign m09_axis_tdata  = s_axis_tdata;
	assign m09_axis_tvalid = s_axis_tvalid;
	assign m09_axis_tlast  = s_axis_tlast;

	assign m10_axis_tdata  = s_axis_tdata;
	assign m10_axis_tvalid = s_axis_tvalid;
	assign m10_axis_tlast  = s_axis_tlast;

	assign m11_axis_tdata  = s_axis_tdata;
	assign m11_axis_tvalid = s_axis_tvalid;
	assign m11_axis_tlast  = s_axis_tlast;

	assign m12_axis_tdata  = s_axis_tdata;
	assign m12_axis_tvalid = s_axis_tvalid;
	assign m12_axis_tlast  = s_axis_tlast;

	assign m13_axis_tdata  = s_axis_tdata;
	assign m13_axis_tvalid = s_axis_tvalid;
	assign m13_axis_tlast  = s_axis_tlast;

	assign m14_axis_tdata  = s_axis_tdata;
	assign m14_axis_tvalid = s_axis_tvalid;
	assign m14_axis_tlast  = s_axis_tlast;

	assign m15_axis_tdata  = s_axis_tdata;
	assign m15_axis_tvalid = s_axis_tvalid;
	assign m15_axis_tlast  = s_axis_tlast;

	reg [OUTPUT_CNT:0] state;
	initial state = 0;

	wire [OUTPUT_CNT-1:0] treadies;
	assign treadies = {
		m00_axis_tready,
		m01_axis_tready,
		m02_axis_tready,
		m03_axis_tready,
		m04_axis_tready,
		m05_axis_tready,
		m06_axis_tready,
		m07_axis_tready,
		m08_axis_tready,
		m09_axis_tready,
		m10_axis_tready,
		m11_axis_tready,
		m12_axis_tready,
		m13_axis_tready,
		m14_axis_tready,
		m15_axis_tready
	};

	wire read_complete;
	wire write_complete;
	wire slave_tready;
	assign read_complete  = read_completes[state];
	assign write_complete = write_completes[state];
	assign slave_tready   = treadies[state];
	assign read_enables   = (!read_completes) & (16'b1 << state);

	assign s_axis_tready = slave_tready && global_ready;

	always @(negedge axis_clock) begin
		if (state >= OUTPUT_CNT || !axis_aresetn) begin
			state <= 0;
		end else begin
			if (read_complete) begin
				state <= state + 1;
			end
		end
	end
endmodule
