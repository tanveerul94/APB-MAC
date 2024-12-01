`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

class scoreboard;
  mailbox driv2sb;
  mailbox mon2sb;
  static bit [2*`OPERAND_WIDTH-1:0] mac_out;
  static bit [16:0] co = 1;
  
  transaction d_trans;
  transaction m_trans;
  
  function new(mailbox driv2sb, mon2sb);
    this.driv2sb=driv2sb;
    this.mon2sb=mon2sb;
  endfunction
  
  task main(input int count);
    $display("------------------Scoreboard Test Starts--------------------");
    repeat(count) begin
      apb_model();
      mon2sb.get(m_trans);


      
/*      if(m_trans.PRDATA != d_trans.PRDATA )
        $display("Failed : PADDR=%h PWDATA=%h Expected PRDATA=%h  Resulted PRDATA=%h",d_trans.PADDR,d_trans.PWDATA, d_trans.PRDATA, m_trans.PRDATA);
      else
        $display("Passed : PADDR=%h PWDATA=%h Expected PRDATA=%h  Resulted PRDATA=%h",d_trans.PADDR,d_trans.PWDATA,d_trans.PRDATA, m_trans.PRDATA);
    end
    $display("------------------Scoreboard Test Ends--------------------");
*/    case (d_trans.TEST)
  	  0:
      begin
        if(d_trans.PADDR != 255)
        begin
          if(m_trans.PRDATA == d_trans.PWDATA && m_trans.PSLVERR == d_trans.PSLVERR)
          $display("Passed : PADDR=%h Expected PRDATA=%h  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PWDATA, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR);
          else
          $display("Failed : PADDR=%h Expected PRDATA=%h  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PWDATA, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR);
        end
        else
        begin
          if(m_trans.PRDATA == 0 && m_trans.PSLVERR == d_trans.PSLVERR)
          $display("Passed : PADDR=%h Expected PRDATA=0  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR);
          else
          $display("Failed : PADDR=%h Expected PRDATA=0  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR); 
        end
      end
  
      1:
      begin
        if(m_trans.PRDATA == 0 && m_trans.PSLVERR == d_trans.PSLVERR)
          $display("Passed : PADDR=%h Expected PRDATA=0  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR);
        else
          $display("Failed : PADDR=%h Expected PRDATA=0  Resulted PRDATA=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR, m_trans.PRDATA,d_trans.PSLVERR, m_trans.PSLVERR);
      end
  
      2:
      begin
        if(m_trans.PSLVERR == d_trans.PSLVERR)
          $display("Passed : PADDR=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PSLVERR, m_trans.PSLVERR);
        else
          $display("Failed : PADDR=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PSLVERR, m_trans.PSLVERR);
      end  
  
      3:
      begin
        if(m_trans.PSLVERR == d_trans.PSLVERR)
          $display("Passed : PADDR=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PSLVERR, m_trans.PSLVERR);
        else
          $display("Failed : PADDR=%h Expected PSLVERR=%d  Resulted PSLVERR=%d",d_trans.PADDR,d_trans.PSLVERR, m_trans.PSLVERR);
      end    

  	  4:
      begin
        if(m_trans.BOOTH_OUTPUT == mac_out)
//          $display("Passed : PWDATA = %h Expected MAC=%h  Resulted MAC=%h",d_trans.PWDATA,mac_out, m_trans.BOOTH_OUTPUT);
        begin
          $write("%0d",co);
          if(co%16 == 0)
            $write("\n");
          else
            $write(",");
          co++;
        end
      else
      begin
        $display("Failed : PWDATA = %h Expected MAC=%h  Resulted MAC=%h",d_trans.PWDATA,mac_out, m_trans.BOOTH_OUTPUT);
        $finish;
      end
      end
  
      5:
      begin
        if(m_trans.BOOTH_OUTPUT == 0 && m_trans.PRDATA == 0)
          $display("Passed : PADDR=000000FF Expected BOOTH_OUTPUT=0  Resulted BOOTH_OUTPUT=%h Expected PRDATA=0  Resulted PRDATA=%h",m_trans.BOOTH_OUTPUT, m_trans.PRDATA);
        else
          $display("Failed : PADDR=000000FF Expected BOOTH_OUTPUT=0  Resulted BOOTH_OUTPUT=%h Expected PRDATA=0  Resulted PRDATA=%h",m_trans.BOOTH_OUTPUT, m_trans.PRDATA);
      end    
	  endcase
    end
    $display("------------------Scoreboard Test Ends--------------------");
    
  endtask:main

  task automatic apb_model();
    driv2sb.get(d_trans);
    
    if(d_trans.PADDR > 255)
      d_trans.PSLVERR = 1;
    else
      d_trans.PSLVERR = 0;
    
    mac_out = mac_out + d_trans.PWDATA[2*`OPERAND_WIDTH-1:`OPERAND_WIDTH]*d_trans.PWDATA[`OPERAND_WIDTH-1:0];

  endtask:apb_model     
endclass:scoreboard

