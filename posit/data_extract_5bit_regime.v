module data_extract_5bit_regime(
    input  [31:0] flp_a,
    output reg signed [31:0] ra_o,
    output reg [26:0] fract_a,
    output reg [2:0]  exp_a
);

reg [30:0] regime_a;
reg [25:0] fract_1a;

always @(*) begin
    regime_a = flp_a[30:0];
    
    casez(regime_a)
        
        // Regime = +4: 5 ones, then terminator 0
        31'b11111_0????_?????_?????_?????_?????_?: begin
            ra_o = 4;
            exp_a = flp_a[24:22];
            fract_1a = {4'b0, flp_a[21:0]};
            fract_a = {1'b1, fract_1a[21:0], 4'b0};
        end

        // Regime = +3: 4 ones, then terminator 0
        31'b11110_?????_?????_?????_?????_?????_?: begin
            ra_o = 3;
            exp_a = flp_a[25:23];
            fract_1a = {3'b0, flp_a[22:0]};
            fract_a = {1'b1, fract_1a[22:0], 3'b000};
        end

        // Regime = +2: 3 ones, then terminator 0
        31'b1110?_?????_?????_?????_?????_?????_?: begin
            ra_o = 2;
            exp_a = flp_a[26:24];
            fract_1a = {2'b0, flp_a[23:0]};
            fract_a = {1'b1, fract_1a[23:0], 2'b00};
        end

        // Regime = +1: 2 ones, then terminator 0
        31'b110??_?????_?????_?????_?????_?????_?: begin
            ra_o = 1;
            exp_a = flp_a[27:25];
            fract_1a = {1'b0, flp_a[24:0]};
            fract_a = {1'b1, fract_1a[24:0], 1'b0};
        end

        // Zero regime: single 1 then terminator 0 (regime = 0)
        31'b10???_?????_?????_?????_?????_?????_?: begin
            ra_o = 0;
            exp_a = flp_a[28:26];
            fract_a = {1'b1, flp_a[25:0]};
        end

        // Regime = -1: 1 zero, then terminator 1
        31'b01???_?????_?????_?????_?????_?????_?: begin
            ra_o = -1;
            exp_a = flp_a[28:26];
            fract_1a = flp_a[25:0];
            fract_a = {1'b1, fract_1a};
        end

        // Regime = -2: 2 zeros, then terminator 1
        31'b001??_?????_?????_?????_?????_?????_?: begin
            ra_o = -2;
            exp_a = flp_a[27:25];
            fract_1a = {1'b0, flp_a[24:0]};
            fract_a = {1'b1, fract_1a[24:0], 1'b0};
        end

        // Regime = -3: 3 zeros, then terminator 1
        31'b0001?_?????_?????_?????_?????_?????_?: begin
            ra_o = -3;
            exp_a = flp_a[26:24];
            fract_1a = {2'b0, flp_a[23:0]};
            fract_a = {1'b1, fract_1a[23:0], 2'b00};
        end

        // Regime = -4: 4 zeros, then terminator 1
        31'b00001_?????_?????_?????_?????_?????_?: begin
            ra_o = -4;
            exp_a = flp_a[25:23];
            fract_1a = {3'b0, flp_a[22:0]};
            fract_a = {1'b1, fract_1a[22:0], 3'b000};
        end

        // Regime = -5: 5 zeros, then terminator 1
        31'b00000_1????_?????_?????_?????_?????_?: begin
            ra_o = -5;
            exp_a = flp_a[24:22];
            fract_1a = {4'b0, flp_a[21:0]};
            fract_a = {1'b1, fract_1a[21:0], 4'b0};
        end

        // Default case (should not happen for valid posits)
        default: begin
            ra_o = 0;
            fract_a = 27'b0;
            exp_a = 3'b0;
        end
    endcase
end
endmodule