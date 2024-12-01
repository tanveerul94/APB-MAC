`include "environment.sv"

module test(input int count, apb_if apbif);
  environment env;

  // Write-Read Test
  class testcase0 extends transaction;
    constraint c_PADDR {
      PADDR inside {[0:255]};
      //s inside {[14:15]};
    }
    
    
    virtual function transaction copy() ;
      testcase0 test;
      test = new();
   	  test.PADDR = PADDR;
      test.PWDATA = PWDATA;
      test.PRDATA = PRDATA;
      test.PSLVERR = PSLVERR;
      test.TEST = TEST;
      return test;
    endfunction
    
  endclass:testcase0
  
  initial begin
    testcase0 trans;
    trans=new();
    trans.TEST = 0;
    env=new(apbif);
    env.gen.blueprint=trans;
    #5;
    env.main(count);
  end
  
  
endmodule:test

