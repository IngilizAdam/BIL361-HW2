`timescale 1ns/1ps

module onbellek (
    // Saat ve reset
    input               clk_i,
    input               rst_i,

    // Anabellek istek sinyalleri
    output  [31:0]      anabellek_istek_adres_o,        // Istegin yapildigi adres 
    output  [255:0]     anabellek_istek_veri_o,         // Istekle yazilacak veri
    output              anabellek_istek_gecerli_o,      // Istek gecerli
    output              anabellek_istek_yaz_gecerli_o,  // Istek yazma istegi
    input               anabellek_istek_hazir_i,        // Anabellek istegi kabul etmeye hazir

    // Anabellek yanit sinyalleri
    input   [255:0]     anabellek_yanit_veri_i,         // Okunan veri
    input               anabellek_yanit_gecerli_i,      // Okunan veri gecerli
    output              anabellek_yanit_hazir_o,        // Modul okunan veriyi kabul etmeye hazir

    // Module istek sinyalleri
    input   [31:0]      istek_adres_i,                  // Istegin yapildigi adres
    input   [31:0]      istek_veri_i,                   // Istekle yazilacak veri
    input               istek_gecerli_i,                // Istek gecerli
    input               istek_yaz_gecerli_i,            // Istek yazma istegi
    output              istek_hazir_o,                  // Modul istegi kabul etmeye hazir

    // Modulun yanit sinyalleri
    output  [31:0]      yanit_veri_o,                   // Modulden okunan veri       
    output              yanit_gecerli_o,                // Modulden okunan veri gecerli
    input               yanit_hazir_i                   // Dis modul veriyi kabul etmeye hazir
);

reg  [31:0]      anabellek_istek_adres_r;
reg  [31:0]      anabellek_istek_adres_ns;

reg  [255:0]     anabellek_istek_veri_r;
reg  [255:0]     anabellek_istek_veri_ns;

reg              anabellek_istek_gecerli_r;
reg              anabellek_istek_gecerli_ns;

reg              anabellek_istek_yaz_gecerli_r;
reg              anabellek_istek_yaz_gecerli_ns;

reg              anabellek_yanit_hazir_r;
reg              anabellek_yanit_hazir_ns;

reg              istek_hazir_r;
reg              istek_hazir_ns;

reg  [31:0]      yanit_veri_r;
reg  [31:0]      yanit_veri_ns;

reg              yanit_gecerli_r;
reg              yanit_gecerli_ns;

localparam DURUM_BOSTA      = 0;
localparam DURUM_OKU_ISTEK  = 1;
localparam DURUM_YAZ_ISTEK  = 2;
localparam DURUM_BEKLE      = 3;
localparam DURUM_YAZ        = 4;
localparam DURUM_OKU        = 5;
localparam DURUM_YANIT      = 6;

reg [2:0] durum_r;
reg [2:0] durum_ns;

reg [255:0] arabellek_obek_r;
reg [255:0] arabellek_obek_ns;

reg [31:0] arabellek_adres_r;
reg [31:0] arabellek_adres_ns;

reg [31:0] arabellek_veri_r;
reg [31:0] arabellek_veri_ns;

reg        arabellek_yaz_istek_r;
reg        arabellek_yaz_istek_ns;

// Verilen veri obegi icerisinde ilgili baytlara veriyi yaz
function [255:0] obege_yaz (
    input [255:0] veri_obegi,
    input [31:0] adres,
    input [31:0] veri
);

integer i;
reg [4:0] bayt_adresi;

begin
    bayt_adresi = adres[4:0] & 5'b11100; // 32 bite hizala
    obege_yaz = veri_obegi;
    // Little Endian
    for (i = 0; i < 4; i = i + 1) begin
        obege_yaz[(bayt_adresi + i) * 8 +: 8] = veri[i * 8 +: 8];
    end
end
endfunction

// Verilen veri obegi icerisinden ilgili baytlari oku
function [31:0] obekten_oku (
    input [255:0] veri_obegi,
    input [31:0] adres
);

integer i;
reg [4:0] bayt_adresi;

begin
    bayt_adresi = adres[4:0] & 5'b11100; // 32 bite hizala
    obekten_oku = 0;
    // Little Endian
    for (i = 0; i < 4; i = i + 1) begin
        obekten_oku[i * 8 +: 8] = veri_obegi[(bayt_adresi + i) * 8 +: 8];
    end
end
endfunction

always @* begin
    anabellek_istek_adres_ns = anabellek_istek_adres_r;
    anabellek_istek_veri_ns = anabellek_istek_veri_r;
    anabellek_istek_gecerli_ns = anabellek_istek_gecerli_r;
    anabellek_istek_yaz_gecerli_ns = anabellek_istek_yaz_gecerli_r;
    anabellek_yanit_hazir_ns = 0;
    istek_hazir_ns = 0;
    yanit_gecerli_ns = 0;
    yanit_veri_ns = yanit_veri_r;
    durum_ns = durum_r;
    arabellek_obek_ns = arabellek_obek_r;
    arabellek_adres_ns = arabellek_adres_r;
    arabellek_veri_ns = arabellek_veri_r;
    arabellek_yaz_istek_ns = arabellek_yaz_istek_r;

    case(durum_r)
    // Herhangi bir istek yok
    DURUM_BOSTA: begin
        istek_hazir_ns = 1;
        if (istek_hazir_o && istek_gecerli_i) begin
            istek_hazir_ns = 0;
            arabellek_adres_ns = istek_adres_i;
            arabellek_veri_ns = istek_veri_i;
            arabellek_yaz_istek_ns = istek_yaz_gecerli_i;
            durum_ns = DURUM_OKU_ISTEK;
        end
    end
    // Anabellege okuma istegi gonderiyoruz, anabellek istegimizi kabul edene kadar (hazir ve gecerli) bekle.
    DURUM_OKU_ISTEK: begin
        anabellek_istek_gecerli_ns = 1;
        anabellek_istek_yaz_gecerli_ns = 0;
        anabellek_istek_adres_ns = arabellek_adres_r;
        anabellek_istek_veri_ns = arabellek_obek_r;
        if (anabellek_istek_hazir_i && anabellek_istek_gecerli_o) begin
            anabellek_istek_gecerli_ns = 0;
            durum_ns = DURUM_BEKLE;
        end
    end
    // Anabellege yazma istegi gonderiyoruz, anabellek istegimizi kabul edene kadar (hazir ve gecerli) bekle.
    DURUM_YAZ_ISTEK: begin
        anabellek_istek_gecerli_ns = 1;
        anabellek_istek_yaz_gecerli_ns = 1;
        anabellek_istek_adres_ns = arabellek_adres_r;
        anabellek_istek_veri_ns = arabellek_obek_r;
        if (anabellek_istek_hazir_i && anabellek_istek_gecerli_o) begin
            anabellek_istek_gecerli_ns = 0;
            anabellek_istek_yaz_gecerli_ns = 0;
            durum_ns = DURUM_BOSTA;
        end
    end
    // Anabellege okuma istegimizi gonderdik, yanit vermesini bekliyoruz.
    DURUM_BEKLE: begin
        anabellek_yanit_hazir_ns = 1;
        if (anabellek_yanit_hazir_o && anabellek_yanit_gecerli_i) begin
            anabellek_yanit_hazir_ns = 0;
            arabellek_obek_ns = anabellek_yanit_veri_i;
            durum_ns = arabellek_yaz_istek_r ? DURUM_YAZ : DURUM_OKU;
        end
    end
    // Anabellekten gelen veri obeginin uzerine veriyi yaz, sonra obegi geri anabellege yaz.
    DURUM_YAZ: begin
        arabellek_obek_ns = obege_yaz(arabellek_obek_r, arabellek_adres_r, arabellek_veri_r);
        durum_ns = DURUM_YAZ_ISTEK;
    end
    // Anabellekten gelen veri obeginin icinden istenen 32 biti oku ve yanitla.
    DURUM_OKU: begin
        yanit_veri_ns = obekten_oku(arabellek_obek_r, arabellek_adres_r);
        durum_ns = DURUM_YANIT;
    end
    // Istegi yapan modulun hazir olmasini bekle.
    DURUM_YANIT: begin
        yanit_gecerli_ns = 1;
        if (yanit_hazir_i && yanit_gecerli_o) begin
            yanit_gecerli_ns = 0;
            durum_ns = DURUM_BOSTA;
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (rst_i) begin
        durum_r <= DURUM_BOSTA;
        anabellek_istek_adres_r <= 0;
        anabellek_istek_veri_r <= 0;
        anabellek_istek_gecerli_r <= 0;
        anabellek_istek_yaz_gecerli_r <= 0;
        anabellek_yanit_hazir_r <= 0;
        istek_hazir_r <= 0;
        yanit_veri_r <= 0;
        yanit_gecerli_r <= 0;
        arabellek_obek_r <= 0;
    end
    else begin
        durum_r <= durum_ns;
        anabellek_istek_adres_r <= anabellek_istek_adres_ns;
        anabellek_istek_veri_r <= anabellek_istek_veri_ns;
        anabellek_istek_gecerli_r <= anabellek_istek_gecerli_ns;
        anabellek_istek_yaz_gecerli_r <= anabellek_istek_yaz_gecerli_ns;
        anabellek_yanit_hazir_r <= anabellek_yanit_hazir_ns;
        istek_hazir_r <= istek_hazir_ns;
        yanit_veri_r <= yanit_veri_ns;
        yanit_gecerli_r <= yanit_gecerli_ns;
        arabellek_obek_r <= arabellek_obek_ns;
        arabellek_adres_r <= arabellek_adres_ns;
        arabellek_veri_r <= arabellek_veri_ns;
        arabellek_yaz_istek_r <= arabellek_yaz_istek_ns;
    end
end

assign anabellek_istek_adres_o = anabellek_istek_adres_r;
assign anabellek_istek_veri_o = anabellek_istek_veri_r;
assign anabellek_istek_gecerli_o = anabellek_istek_gecerli_r;
assign anabellek_istek_yaz_gecerli_o = anabellek_istek_yaz_gecerli_r;
assign anabellek_yanit_hazir_o = anabellek_yanit_hazir_r;
assign istek_hazir_o = istek_hazir_r;
assign yanit_veri_o = yanit_veri_r;
assign yanit_gecerli_o = yanit_gecerli_r;

endmodule
