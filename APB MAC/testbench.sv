`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

//`include "testcase0.sv"
//`include "testcase1.sv"
//`include "testcase2.sv"
//`include "testcase3.sv"
`include "testcase4.sv"
//`include "testcase5.sv"
`include "interface.sv"

module testbench;
  bit 						 PCLK;
  
  initial begin
    forever #5 PCLK =~PCLK;
  end
  
  apb_if apbif(PCLK);
  
  apb_mac_design DUT (
    .PADDR(apbif.PADDR),
    .PWDATA(apbif.PWDATA),
    .PRDATA(apbif.PRDATA),
    .PCLK (PCLK),
    .PRESETn (apbif.PRESETn),
    .PSELx (apbif.PSELx),
	.PENABLE (apbif.PENABLE),
    .PWRITE (apbif.PWRITE),
    .BOOTH_OUTPUT (apbif.BOOTH_OUTPUT),
	.PREADY (apbif.PREADY),
	.PSLVERR (apbif.PSLVERR),
    .BOOTH_READY (apbif.BOOTH_READY)
    );
  
//  int count=256; //testcase0, testcase1  
//  int count=25; //testcase2, testcase3  
  int count=65536; // testcase4
//  int count = 1; //testcase5
  test test01(.count(count),.apbif(apbif));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule


