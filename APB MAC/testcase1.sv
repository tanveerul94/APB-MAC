`include "environment.sv"

module test(input int count, apb_if apbif);
  environment env;

  // Begin Test
  class testcase1 extends transaction;
    constraint c_PADDR {
      PADDR inside {[0:255]};
      //s inside {[14:15]};
    }
    
    
    virtual function transaction copy() ;
      testcase1 test;
      test = new();
   	  test.PADDR = PADDR;
      test.PWDATA = PWDATA;
      test.PRDATA = PRDATA;
      test.PSLVERR = PSLVERR;
      test.TEST = TEST;
      return test;
    endfunction
    
  endclass:testcase1
  
  initial begin
    testcase1 trans;
    trans=new();
    trans.TEST = 1;
    env=new(apbif);
    env.gen.blueprint=trans;
    #5;
    env.main(count);
  end
  
  
endmodule:test

