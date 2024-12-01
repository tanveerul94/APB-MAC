`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

`ifndef SLAVE_BASE
	`define	SLAVE_BASE 32'h0000_0000
`endif

module apb_wp_design (
  input                               PCLK,   	// Sys-Peri Clock
  input                               PRESETn,	// Sys-Peri Asynchronous reset active low
	input				[31:0]									PADDR,		// Sys-Peri address
	input																PSELx,		// Sys-Peri select  
	input																PENABLE,	// Sys-Peri enable
	input																PWRITE,		// Sys-Peri (~Read)/Write
	input				[31:0]									PWDATA,		// Sys-Peri write data	
//	input 															TRANSFER, // Sys-Peri transfer (for initial run)
	input				[2*`OPERAND_WIDTH-1:0]	mem_wire_booth_out,
	input																booth_ready,

	output reg													PREADY, 	// Peri-Sys ready
	output reg	[31:0]									PRDATA, 	// Peri-Sys Read data
	output reg													PSLVERR, 	// Peri-Sys error active high
	output reg	[31:0]									mem[0:255]
  );
	
	localparam IDLE = 2'b00;
	localparam SETUP = 2'b01;
	localparam ACCESS = 2'b10;

  reg  				[1:0] 									state_reg; 			// sequential 
  reg  				[1:0]									 	next_state_reg;  // combinational	

	// memory initializtion
	initial
	begin
		for (int i=0; i<256; i++)
		begin
			mem[i] <= 32'h0000_0000;
		end 		
	end

	// memory write	
  always @(posedge PCLK)
  begin
		if ((next_state_reg == ACCESS) & (PWRITE == 1) & ((PADDR - `SLAVE_BASE) < 255))
    begin
			mem[PADDR - `SLAVE_BASE] <= PWDATA;
		end
		else if ((booth_ready) & ((PADDR - `SLAVE_BASE) == 255))
    begin
			mem[255] <= {{{32-2*`OPERAND_WIDTH}{1'b0}}, mem_wire_booth_out};
		end
		else
		begin
//			mem[PADDR - `SLAVE_BASE] <= mem[PADDR - `SLAVE_BASE];
				mem <= mem;
		end
  end

	// memory read
  always @(posedge PCLK, negedge PRESETn)
  begin
		if (~PRESETn)
		begin
			PRDATA <= 0;
		end
		else if ((next_state_reg == ACCESS) & (PWRITE == 0))
		begin
			PRDATA <= mem[PADDR - `SLAVE_BASE];
		end
		else
		begin
			PRDATA <= 0;
		end
  end

  // State Register Difinition
  always @(posedge PCLK, negedge PRESETn)
  begin
    if (~PRESETn) 
    begin
      state_reg <= IDLE;
    end
    else
    begin
      state_reg <= next_state_reg;
    end
  end

// Write definition
  always @(*) 
  begin
    case (state_reg)
      IDLE :
      begin				
				PREADY = 0;
				PSLVERR = 0;
					if (PSELx)
					begin
						next_state_reg = SETUP;
					end
					else
					begin
						next_state_reg = IDLE;
					end
      end

      SETUP :
      begin				
				PREADY = 0;
				PSLVERR = 0;
					if (~PSELx)
					begin
						next_state_reg = IDLE;
					end
					else if (~PENABLE)
					begin
						next_state_reg = SETUP;
					end
					else
					begin
						next_state_reg = ACCESS;
					end
      end

      ACCESS :
      begin
				PREADY = 1;
				PSLVERR = (PADDR - `SLAVE_BASE > 256-1)? 1:0;
				next_state_reg = IDLE;
      end

      default :
      begin
				PREADY = 0;
				PSLVERR = 0;
				next_state_reg = IDLE;
      end
    endcase
  end	
endmodule
