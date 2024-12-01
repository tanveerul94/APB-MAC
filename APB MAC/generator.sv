`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

`include "transaction.sv"

class generator;
  mailbox gen2driv;
  transaction blueprint;
  
  function new(mailbox gen2driv);
    this.gen2driv=gen2driv;
  endfunction
  
  task main(input int count);
    transaction g_trans;
    
    repeat(count) begin
      assert(blueprint.randomize());
      g_trans = blueprint.copy();
      gen2driv.put(g_trans);
    end
  endtask:main
  
endclass:generator

