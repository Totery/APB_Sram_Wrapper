module apb_inf #(
	parameter MEM_DEPTH  = 1024,
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 10
) (
	// APB bus interface
	input pclk_i,
	input prst_n_i,
	input [ADDR_WIDTH+1:0] paddr_i,			// because each word is 4 bytes --> last 2 addr bits must be alligned
	input psel_i,
	input penable_i,
	input pwrite_i,
	
	input [3:0] pstrb_i,
	input [DATA_WIDTH-1:0] pwdata_i,
	
	output wire pready_o,										// write: no waiting cycle  read: 2 waiting cycles
	output reg [DATA_WIDTH-1:0] prdata_o,		// considering sram dout is large --> add 2 beats
	output wire pslverr_o,									// no error response feature
	
	// Memory interface
	input [DATA_WIDTH-1:0] mem_rdata_i,
	output wire mem_en_o,									 // psel & (~penable)
	output wire mem_we_o,									 // can just directly take pwrite_i 
	output wire [3:0] mem_wbe_o,								 // take pstrb_i
	
	output wire [ADDR_WIDTH-1:0] mem_addr_o,	// last 2 bits alligned --> paddr_i[11:2]
	output wire [DATA_WIDTH-1:0] mem_wdata_o	// direct transfer PWDATA to wdata	
);

	assign mem_wdata_o = pwdata_i;
	assign mem_addr_o  = paddr_i[2+:ADDR_WIDTH];
	assign pslverr_o = 1'b0;
	
	assign mem_en_o = psel_i & (~penable_i);
	assign mem_we_o = pwrite_i;
	assign mem_wbe_o = pstrb_i;
	
	// prdata_o
	reg [DATA_WIDTH-1:0] mem_rdata_r;
	always @(posedge pclk_i or negedge prst_n_i) begin
		if (~prst_n_i) begin
			mem_rdata_r <= 'b0;
			prdata_o 		<= 'b0;
		end else begin
			mem_rdata_r <= mem_rdata_i;
			prdata_o 		<= mem_rdata_r;
		end
	end
	
	// pready_o
	// if pwrite = 1 --> insert no waiting cycles
	// if pwrite = 0 --> insert 2 waiting cycles
	
	reg pready_r;				// 0 waiting cycles
	reg pready_d2_r;		// 2 waiting cycles
	reg pready_d1_r;
	
	always @(posedge pclk_i or negedge prst_n_i) begin
		if (~prst_n_i) begin
			pready_r  <= 1'b0;
		end else begin
			if (psel_i & (~penable_i))	pready_r <= 1'b1;
			else												pready_r <= 1'b0;
		end
	end
	
	
	always @(posedge pclk_i or prst_n_i) begin
		if (~prst_n_i)	begin
			pready_d1_r <= 1'b0;
			pready_d2_r <= 1'b0;
		end else begin
			pready_d1_r <= pready_r;
			pready_d2_r <= pready_d1_r;
		end
	end

	assign pready_o = (pwrite_i)? pready_r : pready_d2_r;

endmodule : apb_inf