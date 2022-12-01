`timescale 1ns / 1ps

module tb_onbellek();

reg                 clk_i;
reg                 rst_i;

wire    [31:0]      anabellek_istek_adres_o;
wire    [255:0]     anabellek_istek_veri_o;
wire                anabellek_istek_gecerli_o;
wire                anabellek_istek_yaz_gecerli_o;
wire                anabellek_istek_hazir_i;
wire    [255:0]     anabellek_yanit_veri_i;
wire                anabellek_yanit_gecerli_i;
wire                anabellek_yanit_hazir_o;

anabellek ab (
    .clk_i                  ( clk_i ),
    .rst_i                  ( rst_i ),
    .istek_adres_i          ( anabellek_istek_adres_o ),
    .istek_veri_i           ( anabellek_istek_veri_o ),
    .istek_gecerli_i        ( anabellek_istek_gecerli_o ),
    .istek_yaz_gecerli_i    ( anabellek_istek_yaz_gecerli_o ),
    .istek_hazir_o          ( anabellek_istek_hazir_i ),
    .yanit_veri_o           ( anabellek_yanit_veri_i ),
    .yanit_gecerli_o        ( anabellek_yanit_gecerli_i ),
    .yanit_hazir_i          ( anabellek_yanit_hazir_o )
);

reg     [31:0]      istek_adres_i;
reg     [31:0]      istek_veri_i;
reg                 istek_gecerli_i;
reg                 istek_yaz_gecerli_i;
wire                istek_hazir_o;
wire    [31:0]      yanit_veri_o;
wire                yanit_gecerli_o;
reg                 yanit_hazir_i;

onbellek ob (
    .clk_i                         ( clk_i ),
    .rst_i                         ( rst_i ),
    .anabellek_istek_adres_o       ( anabellek_istek_adres_o ), 
    .anabellek_istek_veri_o        ( anabellek_istek_veri_o ),         
    .anabellek_istek_gecerli_o     ( anabellek_istek_gecerli_o ),
    .anabellek_istek_yaz_gecerli_o ( anabellek_istek_yaz_gecerli_o ),
    .anabellek_istek_hazir_i       ( anabellek_istek_hazir_i ),
    .anabellek_yanit_veri_i        ( anabellek_yanit_veri_i ),
    .anabellek_yanit_gecerli_i     ( anabellek_yanit_gecerli_i ),
    .anabellek_yanit_hazir_o       ( anabellek_yanit_hazir_o ),
    .istek_adres_i                 ( istek_adres_i ),
    .istek_veri_i                  ( istek_veri_i ),
    .istek_gecerli_i               ( istek_gecerli_i ),
    .istek_yaz_gecerli_i           ( istek_yaz_gecerli_i ),
    .istek_hazir_o                 ( istek_hazir_o ),
    .yanit_veri_o                  ( yanit_veri_o ),
    .yanit_gecerli_o               ( yanit_gecerli_o ),
    .yanit_hazir_i                 ( yanit_hazir_i )
);

always begin
    clk_i = 0;
    #5;
    clk_i = 1;
    #5;
end

localparam TEST_LEN = 16384;

integer i;
integer flag;
initial begin
    istek_adres_i = 0;
    istek_veri_i = 0;
    istek_gecerli_i = 0;
    istek_yaz_gecerli_i = 0;
    yanit_hazir_i = 1;
    flag = 1;

    rst_i = 1;
    repeat(10) @(posedge clk_i) #2;
    rst_i = 0;

    for (i = 0; i < TEST_LEN; i = i + 1) begin
        istek_adres_i = i;
        istek_veri_i = (32'hABCD_0000 + i) & 32'hFFFF_FFFC;
        istek_gecerli_i = 1;
        istek_yaz_gecerli_i = 1;
        wait(istek_hazir_o && clk_i); @(posedge clk_i) #2;
    end

    for (i = 0; i < TEST_LEN; i = i + 1) begin
        istek_adres_i = i;
        istek_gecerli_i = 1;
        istek_yaz_gecerli_i = 0;
        wait(istek_hazir_o && clk_i); @(posedge clk_i) #2;
        wait(yanit_gecerli_o && clk_i); @(posedge clk_i) #2;
        if (yanit_veri_o != ((32'hABCD_0000 + i) & 32'hFFFF_FFFC)) begin
            $display("[SIM] Okuma hatası, i = %0d.", i);
            flag = 0;
        end
    end

    if (flag) begin
            $display("[SIM] Test basarili.");
    end
    $finish;
end

endmodule