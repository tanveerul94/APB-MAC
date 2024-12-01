`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

class driver;
  mailbox gen2driv, driv2sb;
  virtual apb_if.DRIVER apbif;
  transaction d_trans;
  event driven;
  
  function new(mailbox gen2driv, driv2sb , virtual apb_if.DRIVER apbif, event driven);
    this.gen2driv=gen2driv;  
    this.apbif=apbif;
    this.driven=driven;
    this.driv2sb=driv2sb;
  endfunction

  task write;
    input [31:0] write_addr;
    input [31:0] write_data;

	begin
	@(posedge apbif.PCLK);
	apbif.PADDR = write_addr;
	apbif.PWRITE = 1'b1;
	apbif.PSELx = 1'b1;
	apbif.PWDATA = write_data;
	@(posedge apbif.PCLK);
	apbif.PENABLE = 1'b1;
	wait(apbif.PREADY)
	@(posedge apbif.PCLK)
	apbif.PWRITE = 1'b0;
	apbif.PADDR = 32'h0000_0000;
	apbif.PSELx = 1'b0;
	apbif.PWDATA = 32'h0000_0000;
	apbif.PENABLE = 1'b0;
	end
  endtask:write
  
  task read;
    input  [31:0] read_addr;
    output [31:0] read_data;
    output        slave_error; 

	begin		
	@(posedge apbif.PCLK);
	apbif.PADDR = read_addr;
	apbif.PWRITE = 1'b0;
	apbif.PSELx = 1'b1;		
	@(posedge apbif.PCLK);
	apbif.PENABLE = 1'b1;
	wait(apbif.PREADY)
    read_data = apbif.PRDATA;
    slave_error = apbif.PSLVERR;
	@(posedge apbif.PCLK);
	apbif.PWRITE = 1'b0;
	apbif.PADDR = 32'h0000_0000;
	apbif.PSELx = 1'b0;
	apbif.PWDATA = 32'h0000_0000;
	apbif.PENABLE = 1'b0;
	end
  endtask:read
  
  task main(input int count);
    repeat(2) @(posedge apbif.PCLK);
    apbif.PRESETn = 1'b1;
    repeat(count) begin
    gen2driv.get(d_trans);
    case (d_trans.TEST)
	0:
    begin
      repeat(2) @(posedge apbif.PCLK);
	  write(d_trans.PADDR, d_trans.PWDATA);
      repeat(2) @(posedge apbif.PCLK);
      read(d_trans.PADDR,d_trans.PRDATA,d_trans.PSLVERR);
      driv2sb.put(d_trans);
      -> driven;
    end
      
    1:
    begin
      repeat(2) @(posedge apbif.PCLK);
      read(d_trans.PADDR,d_trans.PRDATA,d_trans.PSLVERR);
      driv2sb.put(d_trans);
      -> driven;
    end
      
    2:
    begin
      repeat(2) @(posedge apbif.PCLK);
	  write(d_trans.PADDR, d_trans.PWDATA);
      driv2sb.put(d_trans);
      -> driven;
    end
      
    3:
    begin
      repeat(2) @(posedge apbif.PCLK);
      read(d_trans.PADDR,d_trans.PRDATA,d_trans.PSLVERR);
      driv2sb.put(d_trans);
      -> driven;
    end
      
    4:
    begin
      repeat(2) @(posedge apbif.PCLK);
	  write(d_trans.PADDR, d_trans.PWDATA);
      wait(apbif.BOOTH_READY);      
      driv2sb.put(d_trans);
      -> driven;
    end
      
    5:
    begin
      repeat(2) @(posedge apbif.PCLK);
	  write(d_trans.PADDR, d_trans.PWDATA);
      wait(apbif.BOOTH_READY);
      repeat(2) @(posedge apbif.PCLK);
      apbif.PRESETn = 1'b0;
      repeat(2) @(posedge apbif.PCLK);
      apbif.PRESETn = 1'b1;
      repeat(2) @(posedge apbif.PCLK);
      read(32'h0000_00FF,d_trans.PRDATA,d_trans.PSLVERR);
      driv2sb.put(d_trans);
      -> driven;
    end
    endcase
    end    
  endtask:main
endclass:driver

