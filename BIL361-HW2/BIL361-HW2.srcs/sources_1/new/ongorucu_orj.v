`timescale 1ns / 1ps

module ongorucu (
    // Saat ve reset
    input               clk_i,
    input               rst_i,

    // Dallanma cozuldukten sonra gercek sonucu gosteren guncelleme sinyalleri
    input               guncelle_gecerli_i, // Guncelleme aktif
    input               guncelle_atladi_i,  // Ilgili dallanma atladi
    input   [31:0]      guncelle_ps_i,      // Ilgili dallanmanin program sayaci

    // Su anda islenen program sayaci ve buyruk
    input   [31:0]      ps_i,
    input   [31:0]      buyruk_i,

    // Atlama sonucunu belirten sinyaller
    output  [31:0]      atlanan_ps_o,       // Atlanilacak olan program sayaci
    output              atlanan_gecerli_o   // Atlama gecerli
);

reg [31:0]  atlanan_ps_cmb;
reg         atlanan_gecerli_cmb;

// Durağan atlamaz tahmini
always @* begin
    atlanan_ps_cmb = 0;         // Onemsiz
    atlanan_gecerli_cmb = 0;    // Asla atlama
end

assign atlanan_ps_o = atlanan_ps_cmb;
assign atlanan_gecerli_o = atlanan_gecerli_cmb;

endmodule