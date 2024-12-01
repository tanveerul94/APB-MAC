`include "environment.sv"

module test(input int count, apb_if apbif);
  environment env;

  // Write-PSLVERR Test
  class testcase2 extends transaction;
    constraint c_PADDR {
      PADDR inside {[0:9], [256:270]};
      //s inside {[14:15]};
    }
    
    
    virtual function transaction copy() ;
      testcase2 test;
      test = new();
   	  test.PADDR = PADDR;
      test.PWDATA = PWDATA;
      test.PRDATA = PRDATA;
      test.PSLVERR = PSLVERR;
      test.TEST = TEST;
      return test;
    endfunction
    
  endclass:testcase2
  
  initial begin
    testcase2 trans;
    trans=new();
    trans.TEST = 2;
    env=new(apbif);
    env.gen.blueprint=trans;
    #5;
    env.main(count);
  end
  
  
endmodule:test

