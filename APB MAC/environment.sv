`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  mailbox gen2driv;
  mailbox driv2sb;
  mailbox mon2sb;
  
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  
  event driven;
  virtual apb_if apbif;
  
  function new(virtual apb_if apbif);
    this.apbif=apbif;
    gen2driv=new();
    driv2sb=new();
    mon2sb=new();
    
    gen=new(gen2driv);
    drv=new(gen2driv,driv2sb,apbif.DRIVER,driven);
    mon=new(mon2sb,apbif.MONITOR,driven);
    scb=new(driv2sb,mon2sb);   
  endfunction
  
  task main(input int count);
    fork  gen.main(count);
          drv.main(count);
          mon.main(count);
          scb.main(count);
    join
    $finish;
  endtask:main 
endclass:environment

