`include "environment.sv"

module test(input int count, apb_if apbif);
  environment env;

  // Read-PSLVERR Test
  class testcase3 extends transaction;
    constraint c_PADDR {
      PADDR inside {[0:9], [256:270]};
      //s inside {[14:15]};
    }
    
    
    virtual function transaction copy() ;
      testcase3 test;
      test = new();
   	  test.PADDR = PADDR;
      test.PWDATA = PWDATA;
      test.PRDATA = PRDATA;
      test.PSLVERR = PSLVERR;
      test.TEST = TEST;
      return test;
    endfunction
    
  endclass:testcase3
  
  initial begin
    testcase3 trans;
    trans=new();
    trans.TEST = 3;
    env=new(apbif);
    env.gen.blueprint=trans;
    #5;
    env.main(count);
  end
  
  
endmodule:test

