// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


`ifndef one_way_spi_v1_0
`define one_way_spi_v1_0

interface one_way_spi_v1_0();
  logic SS_I;                                            // Slave Select Input
  logic SS_O;                                            // Slave Select Output
  logic SS_T;                                            // Slave Select Tri-State Control
  logic SCK_I;                                           // SPI Clock Input
  logic SCK_O;                                           // SPI Clock Output
  logic SCK_T;                                           // SPI Clock Tri-State Control
  logic IO0_I;                                           // IO0 Input Port
  logic IO0_O;                                           // IO0 Output Port
  logic IO0_T;                                           // IO0 Tri-State Control

  modport MASTER (
    input SS_I, SCK_I, IO0_I, 
    output SS_O, SS_T, SCK_O, SCK_T, IO0_O, IO0_T
    );

  modport SLAVE (
    input SS_I, SCK_I, IO0_I, 
    output SS_O, SS_T, SCK_O, SCK_T, IO0_O, IO0_T
    );

  modport MONITOR (
    input SS_I, SS_O, SS_T, SCK_I, SCK_O, SCK_T, IO0_I, IO0_O, IO0_T
    );

endinterface // one_way_spi_v1_0

`endif