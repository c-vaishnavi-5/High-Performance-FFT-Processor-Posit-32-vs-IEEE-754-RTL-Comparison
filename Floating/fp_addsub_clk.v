module fp_addsub_clk(
    input clk,
    input rst_n,
    input [31:0] A, B,
    input op,
    output reg [31:0] Sum
);
    wire A_sign, B_sign;
    wire [7:0] A_exp, B_exp;
    wire [23:0] A_mant, B_mant;
    
    assign A_sign = A[31];
    assign A_exp = A[30:23];
    assign A_mant = (A_exp == 8'h00 && A[22:0] == 23'h0) ? 24'b0 : {1'b1, A[22:0]};
    
    assign B_sign = B[31];
    assign B_exp = B[30:23];
    assign B_mant = (B_exp == 8'h00 && B[22:0] == 23'h0) ? 24'b0 : {1'b1, B[22:0]};
    
    reg [7:0] numshift_right;
    reg [24:0] A_mant_mod_25, B_mant_mod_25;
    reg [7:0] A_exp_mod;
    
    always @(*) begin
        if (A_exp >= B_exp) begin
            numshift_right = A_exp - B_exp;
            A_mant_mod_25 = {1'b0, A_mant};
            A_exp_mod = A_exp;
            if (numshift_right >= 25)
                B_mant_mod_25 = 25'b0;
            else
                B_mant_mod_25 = {1'b0, B_mant} >> numshift_right;
        end else begin
            numshift_right = B_exp - A_exp;
            B_mant_mod_25 = {1'b0, B_mant};
            A_exp_mod = B_exp;
            if (numshift_right >= 25)
                A_mant_mod_25 = 25'b0;
            else
                A_mant_mod_25 = {1'b0, A_mant} >> numshift_right;
        end
    end
    
    wire [24:0] A_mag_tc, B_mag_tc;
    assign A_mag_tc = (A_sign) ? (~A_mant_mod_25[24:0] + 1'b1) : A_mant_mod_25[24:0];
    assign B_mag_tc = (B_sign) ? (~B_mant_mod_25[24:0] + 1'b1) : B_mant_mod_25[24:0];
    
    wire [24:0] B_modified;
    assign B_modified = (op == 1'b1) ? (~B_mag_tc + 1'b1) : B_mag_tc;
    
    wire signed [25:0] sum_2s_26;
    assign sum_2s_26 = {(A_mag_tc[24] ? 1'b1 : 1'b0), A_mag_tc} + {(B_modified[24] ? 1'b1 : 1'b0), B_modified};
    
    reg sign_sum;
    reg [24:0] abs_mag_25;
    
    always @(*) begin
        if (sum_2s_26[25] == 1'b1) begin
            sign_sum = 1'b1;
            abs_mag_25 = (~sum_2s_26[24:0]) + 1'b1;
        end else begin
            sign_sum = 1'b0;
            abs_mag_25 = sum_2s_26[24:0];
        end
    end
    
    integer i;
    reg [4:0] msb_pos;
    reg [24:0] norm_mant_25;
    reg [7:0] norm_exp;
    
    always @(*) begin
        msb_pos = 5'd0;
        for (i = 24; i >= 0; i = i - 1) begin
            if (abs_mag_25[i] && (msb_pos == 5'd0)) begin
                msb_pos = i;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Sum <= 32'h00000000;
        end else begin
            if (abs_mag_25 == 25'b0) begin
                Sum <= 32'h00000000;
            end else begin
                if (msb_pos > 23) begin
                    norm_mant_25 = abs_mag_25 >> (msb_pos - 23);
                    norm_exp = A_exp_mod + (msb_pos - 23);
                end else begin
                    norm_mant_25 = abs_mag_25 << (23 - msb_pos);
                    norm_exp = A_exp_mod - (23 - msb_pos);
                end
                
                if (norm_exp >= 8'hFF) begin
                    Sum <= {sign_sum, 8'hFF, 23'h000000};
                end else if (norm_exp <= 8'h00) begin
                    Sum <= 32'h00000000;
                end else begin
                    Sum <= {sign_sum, norm_exp[7:0], norm_mant_25[22:0]};
                end
            end
        end
    end
endmodule