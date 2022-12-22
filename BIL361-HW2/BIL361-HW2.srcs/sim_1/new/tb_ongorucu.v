`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: babanfive
// Engineer: 
// 
// Create Date: 12/22/2022 12:04:33 AM
// Design Name: 31
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_ongorucu(

    );
        
    reg                 clk_i;
	reg                 rst_i;
    
    always begin
    	clk_i = 0;
    	#5;
    	clk_i = 1;
    	#5;
	end
	
	reg 				guncelle_gecerli_i;
	reg 				guncelle_atladi_i;
	reg 	[31:0]		guncelle_ps_i;
	reg 	[31:0] 		ps_i;
	reg 	[31:0] 		buyruk_i;
	wire 	[31:0] 		atlanan_ps_o;
	wire 				atlanan_gecerli_o;
	
	reg 	[499:0]  	tutarlilik_sayaci;
	reg 	[499:0]		toplam_dallanma;
	
	ongorucu kahin(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.guncelle_gecerli_i(guncelle_gecerli_i),
	.guncelle_atladi_i(guncelle_atladi_i),
	.guncelle_ps_i(guncelle_ps_i),
	.ps_i(ps_i),
	.buyruk_i(buyruk_i),
	.atlanan_ps_o(atlanan_ps_o),
	.atlanan_gecerli_o(atlanan_gecerli_o)
	);
	
	integer i;
	integer j;
    initial begin
    	guncelle_gecerli_i = 1;
    	guncelle_atladi_i = 0;
    	guncelle_ps_i = 0;
    	ps_i = 0;
    	buyruk_i = 0;
    	tutarlilik_sayaci = 0;
    	toplam_dallanma = 0;
    	
    	rst_i = 1;
    	repeat(10) @(posedge clk_i) #2;
    	guncelle_gecerli_i = 0;
    	rst_i = 0;
    	
    	for (i = 0; i < 5; i = i + 1) begin
    		guncelle_gecerli_i = 1'b0;
    		ps_i = 32'h0230_0010;
    		buyruk_i = 32'h0820_cd63;
    		toplam_dallanma = toplam_dallanma + 1;
    		guncelle_ps_i = ps_i;
    		#10;
    		guncelle_gecerli_i = 1'b1;
    		guncelle_atladi_i = i != 5;
    		tutarlilik_sayaci = tutarlilik_sayaci + (guncelle_atladi_i == atlanan_gecerli_o); 
    		#10;
    		for (j = 1; j < i*2; j = j + 1) begin
    			guncelle_gecerli_i = 1'b0;
    			ps_i = 32'h0230_020e;
    			buyruk_i = 32'hfe41_d0e3;
    			toplam_dallanma = toplam_dallanma + 1;
    			guncelle_ps_i = ps_i;
    			#10;
    			guncelle_gecerli_i = 1'b1;
    			guncelle_atladi_i = i != i*2;
    			tutarlilik_sayaci = tutarlilik_sayaci + (guncelle_atladi_i == atlanan_gecerli_o); 
    			#10;
    			
    			guncelle_gecerli_i = 1'b0;
                ps_i = 32'h0230_020e;
                buyruk_i = 32'hfe41_d0e3;
                toplam_dallanma = toplam_dallanma + 1;
                guncelle_ps_i = ps_i;
                #10;
                guncelle_gecerli_i = 1'b1;
                guncelle_atladi_i = i == i*2-1;
                tutarlilik_sayaci = tutarlilik_sayaci + (guncelle_atladi_i == atlanan_gecerli_o); 
                #10;
    		end
    	end
    	
		$finish;
    end
    
endmodule