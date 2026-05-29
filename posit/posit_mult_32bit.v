// posit_mult_5bit_regime.v
module posit_mult_32bit (
    input         clk,
    input         rst,
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] p
);

localparam [31:0] POSIT32_ZERO = 32'h00000000;
localparam [31:0] POSIT32_NAR  = 32'h80000000;

/* Correct regime limits for 5-bit regime */
localparam integer MAX_K = 4;
localparam integer MIN_K = -5;

/* ---------- Sign & magnitude ---------- */
wire sign_a = a[31];
wire sign_b = b[31];
wire sign_p = sign_a ^ sign_b;

wire [31:0] mag_a = sign_a ? (~a + 1'b1) : a;
wire [31:0] mag_b = sign_b ? (~b + 1'b1) : b;

/* ---------- Special cases ---------- */
wire zero_a = (a == POSIT32_ZERO);
wire zero_b = (b == POSIT32_ZERO);
wire nar_a  = (a == POSIT32_NAR);
wire nar_b  = (b == POSIT32_NAR);

/* ---------- Extract ---------- */
wire signed [31:0] k_a, k_b;
wire [2:0] exp_a, exp_b;
wire [26:0] frac_a, frac_b;

data_extract_5bit_regime ext_a (
    .flp_a   (mag_a),
    .ra_o    (k_a),
    .fract_a (frac_a),
    .exp_a   (exp_a)
);

data_extract_5bit_regime ext_b (
    .flp_a   (mag_b),
    .ra_o    (k_b),
    .fract_a (frac_b),
    .exp_a   (exp_b)
);

/* ---------- Scale ---------- */
wire signed [10:0] scale_a = (k_a <<< 3) + exp_a;
wire signed [10:0] scale_b = (k_b <<< 3) + exp_b;
wire signed [11:0] scale_s = scale_a + scale_b;

/* ---------- Mantissa multiply ---------- */
wire [53:0] mant_prod = frac_a * frac_b;

/* ---------- Normalize ---------- */
wire mant_carry = mant_prod[53];
wire signed [11:0] scale_n =
    mant_carry ? (scale_s + 1'b1) : scale_s;

wire [26:0] mant_n =
    mant_carry ? mant_prod[53:27] : mant_prod[52:26];

/* ---------- Combinational re-encode ---------- */
reg [31:0] p_next;
integer i, pos;
integer k_p;
integer exp_p;
reg [31:0] mag;

always @(*) begin
    p_next = POSIT32_ZERO;

    if (nar_a || nar_b)
        p_next = POSIT32_NAR;
    else if (zero_a || zero_b)
        p_next = POSIT32_ZERO;
    else begin
        k_p   = scale_n >>> 3;
        exp_p = scale_n - (k_p <<< 3);

        if (k_p > MAX_K)
            p_next = sign_p ? POSIT32_NAR : 32'h7FFFFFFF;
        else if (k_p < MIN_K)
            p_next = POSIT32_ZERO;
        else begin
            mag = 32'b0;
            pos = 30;

            if (k_p >= 0) begin
                for (i = 0; i < k_p + 1 && pos >= 0; i = i + 1) begin
                    mag[pos] = 1'b1;
                    pos = pos - 1;
                end
                mag[pos] = 1'b0;
                pos = pos - 1;
            end else begin
                for (i = 0; i < -k_p && pos >= 0; i = i + 1) begin
                    mag[pos] = 1'b0;
                    pos = pos - 1;
                end
                mag[pos] = 1'b1;
                pos = pos - 1;
            end

            mag[pos -: 3] = exp_p[2:0];
            pos = pos - 3;

            // Handle fraction bits based on regime
            if (k_p >= -5 && k_p <= 4) begin
                case (k_p)
                    4: mag[pos -: 22] = mant_n[25:4];
                    3: mag[pos -: 23] = mant_n[25:3];
                    2: mag[pos -: 24] = mant_n[25:2];
                    1: mag[pos -: 25] = mant_n[25:1];
                    0: mag[pos -: 26] = mant_n[25:0];
                    -1: mag[pos -: 26] = mant_n[25:0];
                    -2: mag[pos -: 25] = mant_n[25:1];
                    -3: mag[pos -: 24] = mant_n[25:2];
                    -4: mag[pos -: 23] = mant_n[25:3];
                    -5: mag[pos -: 22] = mant_n[25:4];
                    default: mag[pos -: 26] = mant_n[25:0];
                endcase
            end

            p_next = sign_p ? (~mag + 1'b1) : mag;
        end
    end
end

/* ---------- Register output ---------- */
always @(posedge clk) begin
    if (rst)
        p <= POSIT32_ZERO;
    else
        p <= p_next;
end

endmodule