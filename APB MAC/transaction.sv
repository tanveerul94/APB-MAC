`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

class transaction;
  randc bit [31:0] PADDR;
  randc bit [31:0] PWDATA;
  bit       [31:0] PRDATA;
  bit			   PSLVERR;
  bit 		[2:0]  TEST;
  bit [2*`OPERAND_WIDTH-1:0] BOOTH_OUTPUT;			
  bit						 BOOTH_READY;

  virtual function transaction copy();
    copy = new();
    copy.PADDR = PADDR;
    copy.PWDATA = PWDATA;
    copy.PRDATA = PRDATA;
    copy.PSLVERR = PSLVERR;
    copy.TEST = TEST;
    copy.BOOTH_OUTPUT = BOOTH_OUTPUT;
    copy.BOOTH_READY = BOOTH_READY;
  endfunction
endclass:transaction 
