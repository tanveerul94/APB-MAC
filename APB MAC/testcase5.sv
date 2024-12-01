`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

`include "environment.sv"

module test(input int count, apb_if apbif);
  environment env;

  // MAC Reset Test
  class testcase5 extends transaction;
    constraint c_PWDATA {
      PWDATA inside {[32'h0000_0000:32'h0000_FFFF]};
    }
    constraint c_PADDR {
      PADDR == `SLAVE_BASE;
    }
    
    
    virtual function transaction copy() ;
      testcase5 test;
      test = new();
   	  test.PADDR = PADDR;
      test.PWDATA = PWDATA;
      test.PRDATA = PRDATA;
      test.PSLVERR = PSLVERR;
      test.TEST = TEST;
      test.BOOTH_OUTPUT = BOOTH_OUTPUT;
      test.BOOTH_READY = BOOTH_READY;
      return test;
    endfunction
    
  endclass:testcase5
  
  initial begin
    testcase5 trans;
    trans=new();
    trans.TEST = 5;
    env=new(apbif);
    env.gen.blueprint=trans;
    #5;
    env.main(count);
  end
  
  
endmodule:test

