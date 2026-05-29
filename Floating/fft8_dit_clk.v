module butterfly_unit_clk (
    input clk,
    input rst_n,
    input valid_in,
    input [31:0] Ar, Ai,
    input [31:0] Br, Bi,
    input [31:0] Wr, Wi,
    output reg valid_out,
    output reg [31:0] Xr, Xi,
    output reg [31:0] Yr, Yi
);
    // Stage 1: Complex multiply B*W
    wire [31:0] BWr, BWi, BRi, BIi;
    
    fp_multiplication_clk mul1 (.clk(clk), .rst_n(rst_n), .A(Br), .B(Wr), .Product(BWr));
    fp_multiplication_clk mul2 (.clk(clk), .rst_n(rst_n), .A(Bi), .B(Wi), .Product(BWi));
    fp_multiplication_clk mul3 (.clk(clk), .rst_n(rst_n), .A(Br), .B(Wi), .Product(BRi));
    fp_multiplication_clk mul4 (.clk(clk), .rst_n(rst_n), .A(Bi), .B(Wr), .Product(BIi));
    
    reg valid_stage1;
    reg [31:0] Ar_d1, Ai_d1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_stage1 <= 1'b0;
            Ar_d1 <= 32'h0;
            Ai_d1 <= 32'h0;
        end else begin
            valid_stage1 <= valid_in;
            Ar_d1 <= Ar;
            Ai_d1 <= Ai;
        end
    end
    
    // Stage 2: Subtract/Add for complex result
    wire [31:0] BW_real, BW_imag;
    fp_addsub_clk sub_mul (.clk(clk), .rst_n(rst_n), .A(BWr), .B(BWi), .op(1'b1), .Sum(BW_real));
    fp_addsub_clk add_mul (.clk(clk), .rst_n(rst_n), .A(BRi), .B(BIi), .op(1'b0), .Sum(BW_imag));
    
    reg valid_stage2;
    reg [31:0] Ar_d2, Ai_d2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_stage2 <= 1'b0;
            Ar_d2 <= 32'h0;
            Ai_d2 <= 32'h0;
        end else begin
            valid_stage2 <= valid_stage1;
            Ar_d2 <= Ar_d1;
            Ai_d2 <= Ai_d1;
        end
    end
    
    // Stage 3: Final add/subtract
    wire [31:0] Xr_wire, Xi_wire, Yr_wire, Yi_wire;
    fp_addsub_clk add_r (.clk(clk), .rst_n(rst_n), .A(Ar_d2), .B(BW_real), .op(1'b0), .Sum(Xr_wire));
    fp_addsub_clk add_i (.clk(clk), .rst_n(rst_n), .A(Ai_d2), .B(BW_imag), .op(1'b0), .Sum(Xi_wire));
    fp_addsub_clk sub_r (.clk(clk), .rst_n(rst_n), .A(Ar_d2), .B(BW_real), .op(1'b1), .Sum(Yr_wire));
    fp_addsub_clk sub_i (.clk(clk), .rst_n(rst_n), .A(Ai_d2), .B(BW_imag), .op(1'b1), .Sum(Yi_wire));
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            Xr <= 32'h0;
            Xi <= 32'h0;
            Yr <= 32'h0;
            Yi <= 32'h0;
        end else begin
            valid_out <= valid_stage2;
            Xr <= Xr_wire;
            Xi <= Xi_wire;
            Yr <= Yr_wire;
            Yi <= Yi_wire;
        end
    end
endmodule

// 8-POINT FFT DIT - Clocked
module fft8_dit_clk #(
    parameter [31:0] W0R = 32'h3F800000,  // 1.0
    parameter [31:0] W0I = 32'h00000000,  // 0.0
    parameter [31:0] W1R = 32'h3F3504F3,  // 0.707
    parameter [31:0] W1I = 32'hBF3504F3,  // -0.707
    parameter [31:0] W2R = 32'h00000000,  // 0.0
    parameter [31:0] W2I = 32'hBF800000,  // -1.0
    parameter [31:0] W3R = 32'hBF3504F3,  // -0.707
    parameter [31:0] W3I = 32'hBF3504F3   // -0.707
)(
    input clk,
    input rst_n,
    input valid_in,
    input [31:0] br0_r, br0_i, br1_r, br1_i,
    input [31:0] br2_r, br2_i, br3_r, br3_i,
    input [31:0] br4_r, br4_i, br5_r, br5_i,
    input [31:0] br6_r, br6_i, br7_r, br7_i,
    output reg valid_out,
    output reg [31:0] Xr0, Xi0, Xr1, Xi1,
    output reg [31:0] Xr2, Xi2, Xr3, Xi3,
    output reg [31:0] Xr4, Xi4, Xr5, Xi5,
    output reg [31:0] Xr6, Xi6, Xr7, Xi7
);
    // Stage 1
    wire [31:0] stage1_r [0:7], stage1_i [0:7];
    wire valid_s1;
    
    butterfly_unit_clk bf0 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in),
                            .Ar(br0_r), .Ai(br0_i), .Br(br1_r), .Bi(br1_i), 
                            .Wr(W0R), .Wi(W0I), .valid_out(valid_s1),
                            .Xr(stage1_r[0]), .Xi(stage1_i[0]), 
                            .Yr(stage1_r[1]), .Yi(stage1_i[1]));
    butterfly_unit_clk bf1 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in),
                            .Ar(br2_r), .Ai(br2_i), .Br(br3_r), .Bi(br3_i), 
                            .Wr(W0R), .Wi(W0I), .valid_out(),
                            .Xr(stage1_r[2]), .Xi(stage1_i[2]), 
                            .Yr(stage1_r[3]), .Yi(stage1_i[3]));
    butterfly_unit_clk bf2 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in),
                            .Ar(br4_r), .Ai(br4_i), .Br(br5_r), .Bi(br5_i), 
                            .Wr(W0R), .Wi(W0I), .valid_out(),
                            .Xr(stage1_r[4]), .Xi(stage1_i[4]), 
                            .Yr(stage1_r[5]), .Yi(stage1_i[5]));
    butterfly_unit_clk bf3 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in),
                            .Ar(br6_r), .Ai(br6_i), .Br(br7_r), .Bi(br7_i), 
                            .Wr(W0R), .Wi(W0I), .valid_out(),
                            .Xr(stage1_r[6]), .Xi(stage1_i[6]), 
                            .Yr(stage1_r[7]), .Yi(stage1_i[7]));
    
    // Stage 2
    wire [31:0] stage2_r [0:7], stage2_i [0:7];
    wire valid_s2;
    
    butterfly_unit_clk bf4 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s1),
                            .Ar(stage1_r[0]), .Ai(stage1_i[0]), 
                            .Br(stage1_r[2]), .Bi(stage1_i[2]), 
                            .Wr(W0R), .Wi(W0I), .valid_out(valid_s2),
                            .Xr(stage2_r[0]), .Xi(stage2_i[0]), 
                            .Yr(stage2_r[2]), .Yi(stage2_i[2]));
    butterfly_unit_clk bf5 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s1),
                            .Ar(stage1_r[1]), .Ai(stage1_i[1]), 
                            .Br(stage1_r[3]), .Bi(stage1_i[3]),
                            .Wr(W2R), .Wi(W2I), .valid_out(),
                            .Xr(stage2_r[1]), .Xi(stage2_i[1]), 
                            .Yr(stage2_r[3]), .Yi(stage2_i[3]));
    butterfly_unit_clk bf6 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s1),
                            .Ar(stage1_r[4]), .Ai(stage1_i[4]), 
                            .Br(stage1_r[6]), .Bi(stage1_i[6]),
                            .Wr(W0R), .Wi(W0I), .valid_out(),
                            .Xr(stage2_r[4]), .Xi(stage2_i[4]), 
                            .Yr(stage2_r[6]), .Yi(stage2_i[6]));
    butterfly_unit_clk bf7 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s1),
                            .Ar(stage1_r[5]), .Ai(stage1_i[5]), 
                            .Br(stage1_r[7]), .Bi(stage1_i[7]),
                            .Wr(W2R), .Wi(W2I), .valid_out(),
                            .Xr(stage2_r[5]), .Xi(stage2_i[5]), 
                            .Yr(stage2_r[7]), .Yi(stage2_i[7]));
    
    // Stage 3
    wire [31:0] stage3_r [0:7], stage3_i [0:7];
    wire valid_s3;
    
    butterfly_unit_clk bf8 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s2),
                            .Ar(stage2_r[0]), .Ai(stage2_i[0]), 
                            .Br(stage2_r[4]), .Bi(stage2_i[4]),
                            .Wr(W0R), .Wi(W0I), .valid_out(valid_s3),
                            .Xr(stage3_r[0]), .Xi(stage3_i[0]), 
                            .Yr(stage3_r[4]), .Yi(stage3_i[4]));
    butterfly_unit_clk bf9 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s2),
                            .Ar(stage2_r[1]), .Ai(stage2_i[1]), 
                            .Br(stage2_r[5]), .Bi(stage2_i[5]),
                            .Wr(W1R), .Wi(W1I), .valid_out(),
                            .Xr(stage3_r[1]), .Xi(stage3_i[1]), 
                            .Yr(stage3_r[5]), .Yi(stage3_i[5]));
    butterfly_unit_clk bf10 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s2),
                             .Ar(stage2_r[2]), .Ai(stage2_i[2]), 
                             .Br(stage2_r[6]), .Bi(stage2_i[6]),
                             .Wr(W2R), .Wi(W2I), .valid_out(),
                             .Xr(stage3_r[2]), .Xi(stage3_i[2]), 
                             .Yr(stage3_r[6]), .Yi(stage3_i[6]));
    butterfly_unit_clk bf11 (.clk(clk), .rst_n(rst_n), .valid_in(valid_s2),
                             .Ar(stage2_r[3]), .Ai(stage2_i[3]), 
                             .Br(stage2_r[7]), .Bi(stage2_i[7]),
                             .Wr(W3R), .Wi(W3I), .valid_out(),
                             .Xr(stage3_r[3]), .Xi(stage3_i[3]), 
                             .Yr(stage3_r[7]), .Yi(stage3_i[7]));
    
    // Output registration
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            Xr0 <= 32'h0; Xi0 <= 32'h0;
            Xr1 <= 32'h0; Xi1 <= 32'h0;
            Xr2 <= 32'h0; Xi2 <= 32'h0;
            Xr3 <= 32'h0; Xi3 <= 32'h0;
            Xr4 <= 32'h0; Xi4 <= 32'h0;
            Xr5 <= 32'h0; Xi5 <= 32'h0;
            Xr6 <= 32'h0; Xi6 <= 32'h0;
            Xr7 <= 32'h0; Xi7 <= 32'h0;
        end else begin
            valid_out <= valid_s3;
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