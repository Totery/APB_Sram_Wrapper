`timescale 1ns/10ps

module tb();

	parameter clk_cyc = 10.0;
	parameter mem_depth = 1024;
	parameter addr_bits = 10;

	reg clk, rstn;
	
	always #(clk_cyc/2.0) clk = ~clk;
	
	initial begin
		clk = 0; rstn = 1;
		repeat(10) @(posedge clk); rstn = 0;
		repeat(10) @(posedge clk); rstn = 1;	
	
		// repeat(1<<12) @(posedge clk);
		// $finish();
	end

	wire psel;
	wire penable;
	wire [(addr_bits+2-1):0] paddr;
	
	wire pwrite;
	wire [31:0] pwdata;
	wire pready;
	
	wire [31:0] prdata;
	wire pslverr;
	
	wire [3:0] pstrb_s;
	assign pstrb_s = 4'b1111;
	
	apb_ms_model #(.mem_depth(1024),.mem_abit(10)) u_apb_ms_model(
		//outputs of model, in tb, wire signals connect them
		.psel	(psel),
		.penable (penable),
		.paddr	(paddr),
		.pwrite	(pwrite),
		.pwdata	(pwdata),
		
		
		.pready	(pready),	//inputs of Model
		.prdata (prdata),	//inputs of Model
		
		.clk	(clk),
		.rstn	(rstn)
	);
	
	apb_sram #(.MEM_DEPTH(mem_depth),.ADDR_WIDTH(addr_bits),
	.DATA_WIDTH(32)) u_apb_sram(
		.psel_i             (psel),
		.penable_i          (penable),
		.paddr_i            (paddr),
		.pwrite_i           (pwrite),
		.pstrb_i						(pstrb_s),
		.pwdata_i           (pwdata),
		.pready_o           (pready),	//outputs of DUT
		.prdata_o           (prdata),   //outputs of DUT
		.pslverr_o					(pslverr),        
		.pclk_i         	  (clk),
		.prst_n_i           (rstn)
	);
endmodule