module apb_sram #(
	parameter MEM_DEPTH  = 1024,
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 10
) (
	input pclk_i,
	input prst_n_i,
	input [ADDR_WIDTH+1:0] paddr_i,			// because each word is 4 bytes --> last 2 addr bits must be alligned
	input psel_i,
	input penable_i,
	input pwrite_i,
	
	input [3:0] pstrb_i,
	input [DATA_WIDTH-1:0] pwdata_i,
	
	output wire pready_o,
	output wire [DATA_WIDTH-1:0] prdata_o,
	output wire pslverr_o
);

	// Connection signals
	wire mem_en_s;
	wire mem_we_s;
	wire [3:0] mem_wbe_s;
	wire [ADDR_WIDTH-1:0] mem_addr_s;
	wire [DATA_WIDTH-1:0] wdata_s;
	wire [DATA_WIDTH-1:0] rdata_s;
	
	// Modules instantiations
	apb_inf	#(.MEM_DEPTH	(MEM_DEPTH),
		.DATA_WIDTH		(DATA_WIDTH),
		.ADDR_WIDTH		(ADDR_WIDTH)
	) u_apb_inf (
		.pclk_i			(pclk_i),
		.prst_n_i		(prst_n_i),
		.paddr_i		(paddr_i),
		.psel_i			(psel_i),
		.penable_i	(penable_i),
		.pwrite_i		(pwrite_i),
		.pstrb_i		(pstrb_i),
		.pwdata_i		(pwdata_i),
		.pready_o		(pready_o),
		.prdata_o		(prdata_o),
		.pslverr_o	(pslverr_o),
		
		.mem_rdata_i (rdata_s),
		.mem_en_o		(mem_en_s),
		.mem_we_o		(mem_we_s),
		.mem_wbe_o	(mem_wbe_s),
		.mem_addr_o	(mem_addr_s),
		.mem_wdata_o (wdata_s)
	);
	

	
		sp_sram_wbe4 #(.MEM_DEPTH	(MEM_DEPTH),
		.DATA_WIDTH		(DATA_WIDTH),
		.ADDR_WIDTH		(ADDR_WIDTH)
		) u_sram (
			.clk_i		(pclk_i),
			.rst_n_i	(prst_n_i),
			.en_i			(mem_en_s),
			.we_i			(mem_we_s),
			.wbe_i		(mem_wbe_s),
			.addr_i		(mem_addr_s),
			.wdata_i	(wdata_s),
			.rdata_o	(rdata_s)
		);

endmodule : apb_sram