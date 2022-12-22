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

localparam  OPCODE_DALLANMA  = 7'b1100011;
localparam  FONKSIYON_BEQ = 3'b000;
localparam  FONKSIYON_BNE = 3'b001;
localparam  FONKSIYON_BLT = 3'b100;
localparam  DURUM_GT         = 0;
localparam  DURUM_ZT         = 1;
localparam  DURUM_ZA         = 2;
localparam  DURUM_GA         = 3;

reg [31:0]  atlanan_ps_cmb = 0;
reg         atlanan_gecerli_cmb = 0;

reg [3:0]   genel_gecmis_r = 0;
reg [3:0]   genel_gecmis_ns = 0;

reg [2:0]   gshare_gecmis_tablosu_r [15:0];
reg [1:0]   ongoru_tablosu_r        [15:0][7:0];

reg [3:0]   gshare_guncellenecek_adres;
reg [2:0]   gshare_guncellenecek_veri;
reg         gshare_guncelle = 0;

reg [2:0]   ongoru_tablosu_guncellenecek_adres;
reg [1:0]   ongoru_tablosu_guncellenecek_veri;

wire [6:0]  opcode;
wire [2:0]  fonksiyon;
wire [31:0] anlik;
wire [3:0]  xor_sonuc;
wire [3:0]  guncelle_xor_sonuc;

integer i, j;
initial begin
    for (i = 0; i < 16; i = i + 1) begin
        gshare_gecmis_tablosu_r[i] = 0;
        for (j = 0; j < 8; j = j + 1) begin
            ongoru_tablosu_r[i][j] = 0;
        end
    end
end

always @* begin
    atlanan_ps_cmb = 0;
    atlanan_gecerli_cmb = 0;
    genel_gecmis_ns = genel_gecmis_r;
    gshare_guncelle = 0;

    if (opcode == OPCODE_DALLANMA && (fonksiyon == FONKSIYON_BEQ || fonksiyon == FONKSIYON_BNE || fonksiyon == FONKSIYON_BLT)) begin
        atlanan_ps_cmb = ps_i + anlik;

        case (ongoru_tablosu_r[xor_sonuc][gshare_gecmis_tablosu_r[xor_sonuc]])
        DURUM_GT: begin
            atlanan_gecerli_cmb = 0;
        end
        DURUM_ZT: begin
            atlanan_gecerli_cmb = 0;
        end
        DURUM_ZA: begin
            atlanan_gecerli_cmb = 1;
        end
        DURUM_GA: begin
            atlanan_gecerli_cmb = 1;
        end
        endcase
    end

    if (guncelle_gecerli_i) begin
        genel_gecmis_ns = (genel_gecmis_r << 1) | guncelle_atladi_i;
        gshare_guncellenecek_veri = (gshare_gecmis_tablosu_r[guncelle_xor_sonuc] << 1) | guncelle_atladi_i;
        gshare_guncellenecek_adres = guncelle_xor_sonuc;
        ongoru_tablosu_guncellenecek_adres = gshare_gecmis_tablosu_r[guncelle_xor_sonuc];
        case (ongoru_tablosu_r[guncelle_xor_sonuc][gshare_gecmis_tablosu_r[guncelle_xor_sonuc]])
        DURUM_GT: begin
            if (guncelle_atladi_i) begin
                ongoru_tablosu_guncellenecek_veri = DURUM_ZT;
            end
            else begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GT;
            end
        end
        DURUM_ZT: begin
            if (guncelle_atladi_i) begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GA;
            end
            else begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GT;
            end
        end
        DURUM_ZA: begin
            if (guncelle_atladi_i) begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GA;
            end
            else begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GT;
            end
        end
        DURUM_GA: begin
            if (guncelle_atladi_i) begin
                ongoru_tablosu_guncellenecek_veri = DURUM_GA;
            end
            else begin
                ongoru_tablosu_guncellenecek_veri = DURUM_ZA;
            end
        end
        endcase
        gshare_guncelle = 1;
    end
end

always @(posedge clk_i) begin
    if (rst_i) begin
        genel_gecmis_r <= 0;
        for (i = 0; i < 16; i = i + 1) begin
            gshare_gecmis_tablosu_r[i] = 0;
            for (j = 0; j < 8; j = j + 1) begin
                ongoru_tablosu_r[i][j] = 0;
            end
        end
    end
    else begin
        genel_gecmis_r <= genel_gecmis_ns;
        if (gshare_guncelle) begin
            gshare_gecmis_tablosu_r[gshare_guncellenecek_adres] <= gshare_guncellenecek_veri;
            ongoru_tablosu_r[guncelle_xor_sonuc][ongoru_tablosu_guncellenecek_adres] <= ongoru_tablosu_guncellenecek_veri;
        end
    end
end

assign atlanan_ps_o = atlanan_ps_cmb;
assign atlanan_gecerli_o = atlanan_gecerli_cmb;
assign opcode = buyruk_i[7:0];
assign fonksiyon = buyruk_i[14:12];
assign anlik = {{20{buyruk_i[31:31]}}, buyruk_i[7:7], buyruk_i[30:25], buyruk_i[11:8], 1'b0};
assign xor_sonuc = (genel_gecmis_r ^ ps_i[3:0]);
assign guncelle_xor_sonuc = (genel_gecmis_r ^ guncelle_ps_i[3:0]);

endmodule
