`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: babanfive
// Engineer: kalitimsal olarak bagin olan biri
// 
// Create Date: 12/22/2022 12:04:33 AM
// Design Name: 31
// Module Name: tb_kahinabladevresihedef2023buyukongorucuprojesi
// Project Name: BUYUK ONGORUCU PROJESI HEDEF 2023 OGUZHAN HOCAYI KORKUTAN TESTBENCH
// Target Devices: 
// Tool Versions: 
// Description: I am desperate
// 
// Dependencies: getting no bitches
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
	
    initial begin
        guncelle_gecerli_i = 1;
        guncelle_atladi_i = 0;
        guncelle_ps_i = 0;
        ps_i = 0;
        buyruk_i = 0;

        rst_i = 1;
        repeat(10) @(posedge clk_i) #2;
        guncelle_gecerli_i = 0;
        rst_i = 0;


        ps_i = 32'd31;
        buyruk_i = 32'b0_000000_00000_00001_000_0110_0_1100011; // beq rs1 rs2 #12 || beq imm[11] = 0, imm [4:1] = 0110, func3 = 000, rs1 = 0, rs2 = 1, imm [10:5] = 0, imm[12] = 0; 
        #10; // 1 cevrim bekle
        guncelle_gecerli_i = 1'b0;
        #10;
        guncelle_gecerli_i = 1'b1;
        guncelle_atladi_i = 1'b1;
        guncelle_ps_i = 31'd31;
        @(posedge clk_i) #10;
        $finish;
    end
    
endmodule