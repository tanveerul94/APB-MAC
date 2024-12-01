`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 8
`endif

module booth_radix_4_design (
  input                               clk,    // Clock
  input                               rst_n,  // Asynchronous reset active low
  input							      en,
  input       [`OPERAND_WIDTH-1:0]    a,
  input       [`OPERAND_WIDTH-1:0]    b,

  output reg  [2*`OPERAND_WIDTH-1:0]  MAC,
  output reg                          ready
  );
	
	localparam START = 1'b0;
	localparam SHIFT_ADD = 1'b1;
  localparam A = 3'b000;
  localparam B = 3'b001;
  localparam C = 3'b010;
  localparam D = 3'b011;
  localparam E = 3'b100;
  localparam F = 3'b101;
  localparam G = 3'b110;
  localparam H = 3'b111;

	localparam size = (((`OPERAND_WIDTH >> 1) + 1) << 1) + 1;
  localparam max_count = ((`OPERAND_WIDTH >> 1) << 1) + 4;

	reg [size-1:0] mod_b;
	reg [2*`OPERAND_WIDTH-1:0] Y;

	assign Y = (en)? a:0;
		
  reg   		 state_reg; // sequential 
  reg  			 next_state_reg; // combinational
  reg  [3:0] count_reg;

  reg  [2*`OPERAND_WIDTH-1:0]   mult;
  reg  [2*`OPERAND_WIDTH-1:0]   shifted_Y;
  reg  [2*`OPERAND_WIDTH-1:0]  	c;

	// combinational block
	always @(*)
	begin
		case(mod_b[2:0])
			A:	shifted_Y = 0;
			B:	shifted_Y = Y << (count_reg-2);
			C:	shifted_Y = Y << (count_reg-2);
			D:	shifted_Y = 2*Y << (count_reg-2);
			E:	shifted_Y = -2*Y << (count_reg-2);
			F:	shifted_Y = -Y << (count_reg-2);
			G:	shifted_Y = -Y << (count_reg-2);
			H:	shifted_Y = 0;
			default:	shifted_Y = 0;
		endcase
	end

  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      mult      <= 0;
			MAC				<= 0;
    end
    else if (ready)
    begin
      mult      <= 0;
			MAC				<= MAC;
    end
		else
    begin
      mult      <= mult + shifted_Y;
			MAC				<= MAC	+	shifted_Y;
    end
  end

  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
			mod_b <= 0;
    end
    else if (en)
    begin
			mod_b <= {{{size - `OPERAND_WIDTH - 1}{1'b0}} , b, 1'b0} >> count_reg;    
		end
		else
		begin
			mod_b <= 0;
		end
  end    
	

  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      count_reg <= 0;
    end
		else if (~en)
		begin
      count_reg <= 0;
		end			
    else if (next_state_reg == START)
    begin
      count_reg <= 0;
    end
    else if (next_state_reg == SHIFT_ADD)
    begin
      count_reg <= count_reg + 2;
    end
  end    

  // State Register Difinition
  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      state_reg <= START;
    end
    else
    begin
      state_reg <= next_state_reg;
    end
  end

  // Next State Logic Definition
  always @(*) 
  begin
    case (state_reg)
      START :
      begin
				if (en)
				begin
        next_state_reg = SHIFT_ADD;
				end
				else
				begin
        next_state_reg = START;
				end				
      end

      SHIFT_ADD :
      begin
				if (en)
				begin
        	if (count_reg == max_count) 
        	begin
          	next_state_reg = START;
        	end
        	else
        	begin
          	next_state_reg = SHIFT_ADD;
        	end
      	end
        else
        begin
          next_state_reg = START;
        end				
			end

      default :
      begin
        next_state_reg = START;
      end
    endcase
  end

  // Output Logic Definition
  always @(*) 
  begin
    case (state_reg)
      START :
      begin
        c = 0;
        ready = 0;
      end

      SHIFT_ADD :
      begin
        if (count_reg == max_count) 
        begin
          c = mult;
          ready = 1;
        end
        else
        begin
          c = 0;
          ready = 0;
        end
      end

      default :
      begin
        c = 0;
        ready = 0;        
      end
    endcase  
  end
endmodule
