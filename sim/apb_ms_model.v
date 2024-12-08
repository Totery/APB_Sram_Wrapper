`define MEM_PATH tb.u_apb_sram.u_sram 
//tb-->instantiate apb_sram u_apb_sram --> instantiate sp_sram u_mem

`timescale 1ns/10ps
module apb_ms_model(
	//outputS of the model, generating stimuli for the apb_sram
	psel,
	penable,
	paddr,
	pwrite,
	pwdata,
	
	//outputs of apb_sram, these values input into model to check if apb_sram works correctly
	pready,
	prdata,
	
	//global signals
	clk,
	rstn
);

	parameter mem_depth = 1024;
	parameter mem_abit = 10;
	parameter mem_dw = 32;
	
	input wire clk, rstn;
	
	// Give stimuli to DUT
	output reg psel;
	output reg penable;
	output reg [11 :0] paddr; 

	output reg pwrite;
	
	output reg [31:0] pwdata;
	
	// Receive outcomes of DUT --> for automatic verification
	input wire pready;
	input wire [31:0] prdata;
	
	//write operation
	task apb_write;
	input [11:0] addr;
	input [31:0] wdata;
	
	begin
		@(negedge clk);
		psel = 1; pwrite = 1; paddr = addr; pwdata = wdata;  //T1, set values for all model outputs
		@(negedge clk); 
		
		penable = 1;//T2, pull up penable
		
		while(~pready) begin
			@(negedge clk);
		end		// if pready = 0, then wait
		
		@(negedge clk); //until pready = 1, T3 or Tn
		psel = 0; penable = 0;
	end
	endtask
	
	
	//read operation
	task apb_read;
	//input [31:0] addr;
	input [11:0] addr;	
	output [31:0] rdata;
	
	begin
		@(negedge clk);
		psel = 1; pwrite = 0; paddr = addr; //T1
		
		@(negedge clk);
		penable = 1;  //T2
		
		while(~pready) begin
			@(negedge clk);
		end
		
		rdata = prdata;  // prdata和pready在一个周期
		@(negedge clk);
		psel = 0; penable = 0;
	end
	endtask
	//
	
	//SRAM Data initialization
	integer cnt;
	reg [11:0] addr;
	
	reg [31:0] wdata;
	reg [31:0] rdata;
	reg [31:0] rand ;
	reg [31:0] ref_data;
	
	initial begin
		psel = 0;
		penable = 0;
		paddr = 0;
		pwrite = 0;
		pwdata = 0;
		
		$display("model works");
		@(posedge rstn);
		
		// sram data initialization
		for(cnt = 0; cnt < mem_depth; cnt = cnt + 1) begin
			//$display("111");
			wdata = $urandom();
			`MEM_PATH.mem_r[cnt] = wdata; //sp_sram 中的mem signal
			//$display("222");
			#1;
		end
		
		repeat(2) @(negedge clk);
		$display("initialization of sram done");
		
		//	boarder addr check
		for(cnt = 0; cnt < 4; cnt = cnt+1) begin
			if((cnt == 0)||(cnt==2)) begin
				addr = 0;					// '0 boarder	
			end
			else
				addr = (mem_depth-1) << 2;  // <<2 is because sram depth is 2 bits less than paddr
																		// '1 boarder
			
			if(cnt < 2) begin 		// cnt = 0, write to '0 boarder
														// cnt = 1, write to '1 boarder
				wdata = $random();
				apb_write(addr,wdata);
				
				@(negedge clk);
				ref_data = `MEM_PATH.mem_r[addr>>2]; // copy the mem contents to ref_data
				if(ref_data !== wdata) begin
					$display("Error: APB write error");
					repeat(2) @(negedge clk);
					$finish();
				end		
			end else begin				// cnt = 2, read from '0 boarder 			
														// cnt = 3, read from '1 boarder

				apb_read(addr,rdata);
				ref_data = `MEM_PATH.mem_r[addr >> 2];
				
				if(ref_data !== rdata) begin
					$display("Error:APB read error");
					repeat(2) @(negedge clk);
					$finish();
				end
			end
		end	
		
		$display("Boarder verification done");
		
		// random read/write test
		for(cnt = 0; cnt < (1<<10);cnt = cnt+1) begin
			rand = $random();
			addr = {rand[2+:mem_abit],2'b0}; //10 bits random + 00
			
			if(rand[31]) begin
				wdata = $random();
				apb_write(addr,wdata);
				
				@(negedge clk);
				ref_data = `MEM_PATH.mem_r[addr >> 2];
				if(ref_data !== wdata) begin
					$display("Error: APB write Error");
					repeat(2) @(negedge clk);
					$finish();
				end
			end else begin
				apb_read(addr, rdata);
				ref_data = `MEM_PATH.mem_r[addr >> 2];
				if(ref_data !== rdata) begin
					$display("Error: APB read Error");
					repeat(2) @(negedge clk);
					$finish();
				end
			end
		end
		
		repeat(10) @(posedge clk); #1;
		$display("OK: sim pass");
		$finish();
		
	end

endmodule