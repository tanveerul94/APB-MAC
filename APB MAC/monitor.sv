`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

class monitor;
  mailbox mon2sb;
  virtual apb_if.MONITOR apbif;
  transaction m_trans;
  event driven;
  
  function new(mailbox mon2sb, virtual apb_if.MONITOR apbif, event driven);
    this.mon2sb=mon2sb;
    this.apbif=apbif;
    this.driven=driven;
  endfunction  
  
  task main(input int count);  
    //@(driven);

//    @(negedge apbif.PCLK);
    repeat(count) begin
//    @(negedge apbif.PCLK);
    m_trans=new();
//    read(m_trans.PRDATA, m_trans.PSLVERR);
    wait(driven.triggered);     
//    @(negedge apbif.PCLK);
    m_trans.PRDATA=apbif.PRDATA;
    m_trans.PSLVERR=apbif.PSLVERR;
    m_trans.BOOTH_OUTPUT = apbif.BOOTH_OUTPUT;
    mon2sb.put(m_trans);
    @(negedge apbif.PCLK);
    end
  endtask:main
endclass:monitor

