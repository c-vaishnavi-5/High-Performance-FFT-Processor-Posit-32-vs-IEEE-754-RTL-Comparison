module posit_fft8_dit_clk (
    input clk,
    input rst,
    // Bit-reversed input order: 0,4,2,6,1,5,3,7
    input [31:0] br0_r, br0_i,  // Input 0
    input [31:0] br1_r, br1_i,  // Input 4
    input [31:0] br2_r, br2_i,  // Input 2
    input [31:0] br3_r, br3_i,  // Input 6
    input [31:0] br4_r, br4_i,  // Input 1
    input [31:0] br5_r, br5_i,  // Input 5
    input [31:0] br6_r, br6_i,  // Input 3
    input [31:0] br7_r, br7_i,  // Input 7
    // Natural order outputs: 0,1,2,3,4,5,6,7
    output reg [31:0] Xr0, Xi0,
    output reg [31:0] Xr1, Xi1,
    output reg [31:0] Xr2, Xi2,
    output reg [31:0] Xr3, Xi3,
    output reg [31:0] Xr4, Xi4,
    output reg [31:0] Xr5, Xi5,
    output reg [31:0] Xr6, Xi6,
    output reg [31:0] Xr7, Xi7
);

    // ========================================================================
    // Twiddle factors in Posit32 binary format
    // W^0 = 1 + 0j
    parameter [31:0] W0R = 32'b01000000000000000000000000000000;  // 1.0
    parameter [31:0] W0I = 32'b00000000000000000000000000000000;  // 0.0
    
    // W^1 = 0.707 - 0.707j
    parameter [31:0] W1R = 32'b00111101101001111110111110011110;  // 0.707
    parameter [31:0] W1I = 32'b11000010010110000001000001100010;  // -0.707
    
    // W^2 = 0 - 1j
    parameter [31:0] W2R = 32'b00000000000000000000000000000000;  // 0.0
    parameter [31:0] W2I = 32'b11000000000000000000000000000000;  // -1.0
    
    // W^3 = -0.707 - 0.707j
    parameter [31:0] W3R = 32'b11000010010110000001000001100010;  // -0.707
    parameter [31:0] W3I = 32'b11000010010110000001000001100010;  // -0.707
    // ========================================================================

    // Stage 1: First layer of butterflies (span = 1)
    // All twiddle factors are W^0 = 1
    wire [31:0] stage1_r [0:7];
    wire [31:0] stage1_i [0:7];
    
    posit_butterfly_unit_clk bf0 (
        .clk(clk), .rst(rst),
        .Ar(br0_r), .Ai(br0_i), .Br(br1_r), .Bi(br1_i), 
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage1_r[0]), .Xi(stage1_i[0]), 
        .Yr(stage1_r[1]), .Yi(stage1_i[1])
    );
    
    posit_butterfly_unit_clk bf1 (
        .clk(clk), .rst(rst),
        .Ar(br2_r), .Ai(br2_i), .Br(br3_r), .Bi(br3_i), 
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage1_r[2]), .Xi(stage1_i[2]), 
        .Yr(stage1_r[3]), .Yi(stage1_i[3])
    );
    
    posit_butterfly_unit_clk bf2 (
        .clk(clk), .rst(rst),
        .Ar(br4_r), .Ai(br4_i), .Br(br5_r), .Bi(br5_i), 
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage1_r[4]), .Xi(stage1_i[4]), 
        .Yr(stage1_r[5]), .Yi(stage1_i[5])
    );
    
    posit_butterfly_unit_clk bf3 (
        .clk(clk), .rst(rst),
        .Ar(br6_r), .Ai(br6_i), .Br(br7_r), .Bi(br7_i), 
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage1_r[6]), .Xi(stage1_i[6]), 
        .Yr(stage1_r[7]), .Yi(stage1_i[7])
    );
    
    // Stage 2: Second layer of butterflies (span = 2)
    // Twiddle factors: W^0, W^2, W^0, W^2
    wire [31:0] stage2_r [0:7];
    wire [31:0] stage2_i [0:7];
    
    posit_butterfly_unit_clk bf4 (
        .clk(clk), .rst(rst),
        .Ar(stage1_r[0]), .Ai(stage1_i[0]), 
        .Br(stage1_r[2]), .Bi(stage1_i[2]), 
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage2_r[0]), .Xi(stage2_i[0]), 
        .Yr(stage2_r[2]), .Yi(stage2_i[2])
    );
    
    posit_butterfly_unit_clk bf5 (
        .clk(clk), .rst(rst),
        .Ar(stage1_r[1]), .Ai(stage1_i[1]), 
        .Br(stage1_r[3]), .Bi(stage1_i[3]),
        .Wr(W2R), .Wi(W2I), 
        .Xr(stage2_r[1]), .Xi(stage2_i[1]), 
        .Yr(stage2_r[3]), .Yi(stage2_i[3])
    );
    
    posit_butterfly_unit_clk bf6 (
        .clk(clk), .rst(rst),
        .Ar(stage1_r[4]), .Ai(stage1_i[4]), 
        .Br(stage1_r[6]), .Bi(stage1_i[6]),
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage2_r[4]), .Xi(stage2_i[4]), 
        .Yr(stage2_r[6]), .Yi(stage2_i[6])
    );
    
    posit_butterfly_unit_clk bf7 (
        .clk(clk), .rst(rst),
        .Ar(stage1_r[5]), .Ai(stage1_i[5]), 
        .Br(stage1_r[7]), .Bi(stage1_i[7]),
        .Wr(W2R), .Wi(W2I), 
        .Xr(stage2_r[5]), .Xi(stage2_i[5]), 
        .Yr(stage2_r[7]), .Yi(stage2_i[7])
    );
    
    // Stage 3: Third layer of butterflies (span = 4)
    // Twiddle factors: W^0, W^1, W^2, W^3
    wire [31:0] stage3_r [0:7];
    wire [31:0] stage3_i [0:7];
    
    posit_butterfly_unit_clk bf8 (
        .clk(clk), .rst(rst),
        .Ar(stage2_r[0]), .Ai(stage2_i[0]), 
        .Br(stage2_r[4]), .Bi(stage2_i[4]),
        .Wr(W0R), .Wi(W0I), 
        .Xr(stage3_r[0]), .Xi(stage3_i[0]), 
        .Yr(stage3_r[4]), .Yi(stage3_i[4])
    );
    
    posit_butterfly_unit_clk bf9 (
        .clk(clk), .rst(rst),
        .Ar(stage2_r[1]), .Ai(stage2_i[1]), 
        .Br(stage2_r[5]), .Bi(stage2_i[5]),
        .Wr(W1R), .Wi(W1I), 
        .Xr(stage3_r[1]), .Xi(stage3_i[1]), 
        .Yr(stage3_r[5]), .Yi(stage3_i[5])
    );
    
    posit_butterfly_unit_clk bf10 (
        .clk(clk), .rst(rst),
        .Ar(stage2_r[2]), .Ai(stage2_i[2]), 
        .Br(stage2_r[6]), .Bi(stage2_i[6]),
        .Wr(W2R), .Wi(W2I), 
        .Xr(stage3_r[2]), .Xi(stage3_i[2]), 
        .Yr(stage3_r[6]), .Yi(stage3_i[6])
    );
    
    posit_butterfly_unit_clk bf11 (
        .clk(clk), .rst(rst),
        .Ar(stage2_r[3]), .Ai(stage2_i[3]), 
        .Br(stage2_r[7]), .Bi(stage2_i[7]),
        .Wr(W3R), .Wi(W3I), 
        .Xr(stage3_r[3]), .Xi(stage3_i[3]), 
        .Yr(stage3_r[7]), .Yi(stage3_i[7])
    );
    
    // Output registration
    always @(posedge clk) begin
        if (rst) begin
            Xr0 <= 32'b0; Xi0 <= 32'b0;
            Xr1 <= 32'b0; Xi1 <= 32'b0;
            Xr2 <= 32'b0; Xi2 <= 32'b0;
            Xr3 <= 32'b0; Xi3 <= 32'b0;
            Xr4 <= 32'b0; Xi4 <= 32'b0;
            Xr5 <= 32'b0; Xi5 <= 32'b0;
            Xr6 <= 32'b0; Xi6 <= 32'b0;
            Xr7 <= 32'b0; Xi7 <= 32'b0;
        end else begin
            Xr0 <= stage3_r[0]; Xi0 <= stage3_i[0];
            Xr1 <= stage3_r[1]; Xi1 <= stage3_i[1];
            Xr2 <= stage3_r[2]; Xi2 <= stage3_i[2];
            Xr3 <= stage3_r[3]; Xi3 <= stage3_i[3];
            Xr4 <= stage3_r[4]; Xi4 <= stage3_i[4];
            Xr5 <= stage3_r[5]; Xi5 <= stage3_i[5];
            Xr6 <= stage3_r[6]; Xi6 <= stage3_i[6];
            Xr7 <= stage3_r[7]; Xi7 <= stage3_i[7];
        end
    end

endmodule