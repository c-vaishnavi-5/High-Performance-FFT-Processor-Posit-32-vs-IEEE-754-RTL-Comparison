module posit_butterfly_unit_clk (
    input clk,
    input rst, 
    input [31:0] Ar, Ai,      // Complex input A (real, imaginary)
    input [31:0] Br, Bi,      // Complex input B (real, imaginary)
    input [31:0] Wr, Wi,      // Complex twiddle factor W (real, imaginary)
    output reg [31:0] Xr, Xi, // Complex output X = A + B*W
    output reg [31:0] Yr, Yi  // Complex output Y = A - B*W
);

    // ========================================================================
    // Stage 1: Complex multiplication B*W = (Br + jBi) * (Wr + jWi)
    // Real part: BWr = Br*Wr - Bi*Wi
    // Imag part: BWi = Br*Wi + Bi*Wr
    // ========================================================================
    wire [31:0] BWr_mul1, BWr_mul2; // Br*Wr and Bi*Wi
    wire [31:0] BWi_mul1, BWi_mul2; // Br*Wi and Bi*Wr
    
    posit_mult_32bit mul_br_wr (
        .clk(clk), 
        .rst(rst), 
        .a(Br), 
        .b(Wr), 
        .p(BWr_mul1)
    );
    
    posit_mult_32bit mul_bi_wi (
        .clk(clk), 
        .rst(rst), 
        .a(Bi), 
        .b(Wi), 
        .p(BWr_mul2)
    );
    
    posit_mult_32bit mul_br_wi (
        .clk(clk), 
        .rst(rst), 
        .a(Br), 
        .b(Wi), 
        .p(BWi_mul1)
    );
    
    posit_mult_32bit mul_bi_wr (
        .clk(clk), 
        .rst(rst), 
        .a(Bi), 
        .b(Wr), 
        .p(BWi_mul2)
    );
    
    // Pipeline stage 1: delay A
    reg [31:0] Ar_d1, Ai_d1;
    
    always @(posedge clk) begin
        if (rst) begin
            Ar_d1 <= 32'h0;
            Ai_d1 <= 32'h0;
        end else begin
            Ar_d1 <= Ar;
            Ai_d1 <= Ai;
        end
    end
    
    // ========================================================================
    // Stage 2: Complete complex multiplication
    // BW_real = Br*Wr - Bi*Wi
    // BW_imag = Br*Wi + Bi*Wr
    // ========================================================================
    wire [31:0] BW_real, BW_imag;
    
    posit_addsub_32bit sub_real (
        .clk(clk), 
        .rst(rst), 
        .a(BWr_mul1), 
        .b(BWr_mul2), 
        .op(1'b1),     // subtract
        .p(BW_real)
    );
    
    posit_addsub_32bit add_imag (
        .clk(clk), 
        .rst(rst), 
        .a(BWi_mul1), 
        .b(BWi_mul2), 
        .op(1'b0),     // add
        .p(BW_imag)
    );
    
    // Pipeline stage 2: delay A
    reg [31:0] Ar_d2, Ai_d2;
    
    always @(posedge clk) begin
        if (rst) begin
            Ar_d2 <= 32'h0;
            Ai_d2 <= 32'h0;
        end else begin
            Ar_d2 <= Ar_d1;
            Ai_d2 <= Ai_d1;
        end
    end
    
    // ========================================================================
    // Stage 3: Final butterfly operations
    // X = A + BW
    // Y = A - BW
    // ========================================================================
    wire [31:0] Xr_wire, Xi_wire, Yr_wire, Yi_wire;
    
    posit_addsub_32bit add_xr (
        .clk(clk), 
        .rst(rst), 
        .a(Ar_d2), 
        .b(BW_real), 
        .op(1'b0),     // add
        .p(Xr_wire)
    );
    
    posit_addsub_32bit add_xi (
        .clk(clk), 
        .rst(rst), 
        .a(Ai_d2), 
        .b(BW_imag), 
        .op(1'b0),     // add
        .p(Xi_wire)
    );
    
    posit_addsub_32bit sub_yr (
        .clk(clk), 
        .rst(rst), 
        .a(Ar_d2), 
        .b(BW_real), 
        .op(1'b1),     // subtract
        .p(Yr_wire)
    );
    
    posit_addsub_32bit sub_yi (
        .clk(clk), 
        .rst(rst), 
        .a(Ai_d2), 
        .b(BW_imag), 
        .op(1'b1),     // subtract
        .p(Yi_wire)
    );
    
    // ========================================================================
    // Stage 4: Output registration
    // ========================================================================
    always @(posedge clk) begin
        if (rst) begin
            Xr <= 32'h0;
            Xi <= 32'h0;
            Yr <= 32'h0;
            Yi <= 32'h0;
        end else begin
            Xr <= Xr_wire;
            Xi <= Xi_wire;
            Yr <= Yr_wire;
            Yi <= Yi_wire;
        end
    end

endmodule