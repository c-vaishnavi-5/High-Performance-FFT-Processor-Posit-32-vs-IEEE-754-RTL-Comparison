module fp_multiplication_clk(
    input clk,
    input rst_n,
    input [31:0] A, B,
    output reg [31:0] Product
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
    
    wire [47:0] Prod_mant;
    assign Prod_mant = A_mant * B_mant;
    
    wire [8:0] Prod_exp_temp;
    assign Prod_exp_temp = A_exp + B_exp - 127;
    
    wire Prod_sign;
    assign Prod_sign = A_sign ^ B_sign;
    
    reg [7:0] Norm_exp;
    reg [22:0] Norm_mant;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Product <= 32'h00000000;
        end else begin
            if ((A_exp == 8'h00 && A_mant == 24'h0) || (B_exp == 8'h00 && B_mant == 24'h0)) begin
                Product <= 32'h00000000;
            end
            else if (A_exp == 8'hFF || B_exp == 8'hFF) begin
                Product <= {Prod_sign, 8'hFF, 23'h000000};
            end
            else begin
                if (Prod_mant[47]) begin
                    Norm_mant = Prod_mant[46:24];
                    Norm_exp = Prod_exp_temp + 1;
                end else begin
                    Norm_mant = Prod_mant[45:23];
                    Norm_exp = Prod_exp_temp;
                end
                
                if (Prod_exp_temp[8] || Norm_exp >= 8'hFF) begin
                    Product <= {Prod_sign, 8'hFF, 23'h000000};
                end
                else if (Norm_exp <= 8'h00) begin
                    Product <= {Prod_sign, 8'h00, 23'h000000};
                end
                else begin
                    Product <= {Prod_sign, Norm_exp, Norm_mant};
                end
            end
        end
    end
endmodule