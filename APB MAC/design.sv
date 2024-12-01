`include "apb_wp_design.sv"
`include "booth_radix_4_design.sv"

`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

module apb_mac_design (
  input         PCLK,   	// Sys-Peri Clock
  input         PRESETn,	// Sys-Peri Asynchronous reset active low
  input	 [31:0] PADDR,		// Sys-Peri address
  input		    PSELx,		// Sys-Peri select  
  input		    PENABLE,	// Sys-Peri enable
  input	 	    PWRITE,		// Sys-Peri (~Read)/Write
  input	 [31:0] PWDATA,		// Sys-Peri write data	
//	input 															TRANSFER, // Sys-Peri transfer (for initial run)
		
  output	    PREADY, 	// Peri-Sys ready
  output [31:0] PRDATA, 	// Peri-Sys Read data
  output		PSLVERR, 	// Peri-Sys error active high
  output [2*`OPERAND_WIDTH-1:0]	BOOTH_OUTPUT,			
  output						BOOTH_READY
  );

  wire				[31:0]									mem[0:255];
  wire 				[31:0]									booth_in;
  wire																booth_en_sig;
  reg																	booth_en;
	
  assign  booth_en_sig = PREADY & PWRITE;
  assign  booth_in = mem[0];

  always @(posedge PCLK, negedge PRESETn)
  begin
    if (~PRESETn) 
    begin
      booth_en      <= 0;
    end
    else if (BOOTH_READY)
    begin
      booth_en      <= 0;
    end
		else if (booth_en_sig)
    begin
      booth_en      <= 1;
    end
		else
		begin
      booth_en      <= booth_en;
		end			
  end

  apb_wp_design apb_wp_test (
    .PCLK (PCLK),
    .PRESETn (PRESETn),
    .PADDR (PADDR),
    .PSELx (PSELx),
	.PENABLE (PENABLE),
    .PWRITE (PWRITE),
    .PWDATA (PWDATA),
//		.TRANSFER (TRANSFER),
	.mem_wire_booth_out (BOOTH_OUTPUT),
	.booth_ready (BOOTH_READY),
	.PREADY (PREADY),
	.PRDATA (PRDATA),
	.PSLVERR (PSLVERR),
	.mem (mem)
    );

  booth_radix_4_design booth_radix_4_test (
    .clk (PCLK),
    .rst_n (PRESETn),
    .a (booth_in[2*`OPERAND_WIDTH-1:`OPERAND_WIDTH]),
    .b (booth_in[`OPERAND_WIDTH-1:0]),
	.en (booth_en),
    .MAC (BOOTH_OUTPUT),
    .ready (BOOTH_READY)
    );
endmodule

