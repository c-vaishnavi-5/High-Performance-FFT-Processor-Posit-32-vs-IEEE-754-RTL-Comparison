module posit_addsub_32bit (
    input         clk,
    input         rst,
    input  [31:0] a,
    input  [31:0] b,
    input         op,      // 0: add, 1: subtract
    output reg [31:0] p
);

/* ---------- Constants ---------- */
localparam [31:0] POSIT32_ZERO = 32'h00000000;
localparam [31:0] POSIT32_NAR  = 32'h80000000;
localparam ES = 3;
localparam MAX_K = 4;
localparam MIN_K = -5;

/* ---------- Special cases ---------- */
wire zero_a = (a == POSIT32_ZERO);
wire zero_b = (b == POSIT32_ZERO);
wire nar_a  = (a == POSIT32_NAR);
wire nar_b  = (b == POSIT32_NAR);

/* ---------- Extract ---------- */
wire sign_a = a[31];
wire sign_b = b[31];

wire [31:0] mag_a = sign_a ? (~a + 1'b1) : a;
wire [31:0] mag_b = sign_b ? (~b + 1'b1) : b;

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

/* ---------- Handle zero cases early ---------- */
wire [31:0] b_effective = op ? {~sign_b, b[30:0]} : b; // For subtract, flip sign of b
wire sign_b_eff = op ? ~sign_b : sign_b;

/* ---------- Scale calculation ---------- */
wire signed [31:0] scale_a = (k_a * 8) + exp_a;
wire signed [31:0] scale_b = (k_b * 8) + exp_b;
wire signed [31:0] scale_diff = scale_a - scale_b;

/* ---------- Alignment ---------- */
reg [26:0] frac_a_aligned, frac_b_aligned;
reg [2:0] exp_aligned;
reg signed [31:0] k_aligned;
reg sign_larger;
reg a_is_larger;

always @(*) begin
    if (scale_a >= scale_b) begin
        a_is_larger = 1;
        // A has larger or equal scale
        if ((scale_a - scale_b) < 27) begin
            frac_b_aligned = frac_b >> (scale_a - scale_b);
        end else begin
            frac_b_aligned = 0;
        end
        frac_a_aligned = frac_a;
        exp_aligned = exp_a;
        k_aligned = k_a;
        sign_larger = sign_a;
    end else begin
        a_is_larger = 0;
        // B has larger scale
        if ((scale_b - scale_a) < 27) begin
            frac_a_aligned = frac_a >> (scale_b - scale_a);
        end else begin
            frac_a_aligned = 0;
        end
        frac_b_aligned = frac_b;
        exp_aligned = exp_b;
        k_aligned = k_b;
        sign_larger = sign_b_eff;
    end
end

/* ---------- Addition/Subtraction ---------- */
reg [27:0] sum_raw;
reg carry;
reg sign_result;

always @(*) begin
    if (op) begin  // Subtraction (A - B)
        if (sign_a == sign_b) begin
            // Same sign subtraction: effectively A + (-B)
            if (a_is_larger) begin
                if (frac_a_aligned >= frac_b_aligned) begin
                    sum_raw[26:0] = frac_a_aligned - frac_b_aligned;
                    carry = 0;
                    sign_result = sign_a;
                end else begin
                    sum_raw[26:0] = frac_b_aligned - frac_a_aligned;
                    carry = 0;
                    sign_result = ~sign_b;
                end
            end else begin
                if (frac_b_aligned >= frac_a_aligned) begin
                    sum_raw[26:0] = frac_b_aligned - frac_a_aligned;
                    carry = 0;
                    sign_result = ~sign_b;
                end else begin
                    sum_raw[26:0] = frac_a_aligned - frac_b_aligned;
                    carry = 0;
                    sign_result = sign_a;
                end
            end
        end else begin
            // Different signs: A - (-B) = A + B
            {carry, sum_raw[26:0]} = frac_a_aligned + frac_b_aligned;
            sign_result = sign_larger;
        end
    end else begin  // Addition
        if (sign_a == sign_b_eff) begin
            // Same sign addition
            {carry, sum_raw[26:0]} = frac_a_aligned + frac_b_aligned;
            sign_result = sign_larger;
        end else begin
            // Different signs: effectively subtraction
            if (a_is_larger) begin
                if (frac_a_aligned >= frac_b_aligned) begin
                    sum_raw[26:0] = frac_a_aligned - frac_b_aligned;
                    carry = 0;
                    sign_result = sign_a;
                end else begin
                    sum_raw[26:0] = frac_b_aligned - frac_a_aligned;
                    carry = 0;
                    sign_result = sign_b_eff;
                end
            end else begin
                if (frac_b_aligned >= frac_a_aligned) begin
                    sum_raw[26:0] = frac_b_aligned - frac_a_aligned;
                    carry = 0;
                    sign_result = sign_b_eff;
                end else begin
                    sum_raw[26:0] = frac_a_aligned - frac_b_aligned;
                    carry = 0;
                    sign_result = sign_a;
                end
            end
        end
    end
    sum_raw[27] = carry;
end

/* ---------- Normalization ---------- */
reg [26:0] mant_final;
reg [2:0] exp_final;
reg signed [31:0] k_final;
reg sign_final;
reg [4:0] leading_zeros;

always @(*) begin
    mant_final = sum_raw[26:0];
    exp_final = exp_aligned;
    k_final = k_aligned;
    sign_final = sign_result;
    
    // Handle carry (overflow)
    if (carry) begin
        mant_final = {1'b1, sum_raw[26:1]};
        if (exp_final == 3'b111) begin
            k_final = k_final + 1;
            exp_final = 3'b000;
        end else begin
            exp_final = exp_final + 1;
        end
    end
    // Handle leading zeros (normalize left)
    else if (mant_final != 0) begin
        // Count leading zeros and shift
        if (!mant_final[26]) begin
            // Find first 1 bit
            leading_zeros = 0;
            if (mant_final[25:0] != 0) begin
                if (mant_final[25]) leading_zeros = 1;
                else if (mant_final[24]) leading_zeros = 2;
                else if (mant_final[23]) leading_zeros = 3;
                else if (mant_final[22]) leading_zeros = 4;
                else if (mant_final[21]) leading_zeros = 5;
                else if (mant_final[20]) leading_zeros = 6;
                else if (mant_final[19]) leading_zeros = 7;
                else if (mant_final[18]) leading_zeros = 8;
                else if (mant_final[17]) leading_zeros = 9;
                else if (mant_final[16]) leading_zeros = 10;
                else if (mant_final[15]) leading_zeros = 11;
                else if (mant_final[14]) leading_zeros = 12;
                else if (mant_final[13]) leading_zeros = 13;
                else if (mant_final[12]) leading_zeros = 14;
                else if (mant_final[11]) leading_zeros = 15;
                else if (mant_final[10]) leading_zeros = 16;
                else if (mant_final[9]) leading_zeros = 17;
                else if (mant_final[8]) leading_zeros = 18;
                else if (mant_final[7]) leading_zeros = 19;
                else if (mant_final[6]) leading_zeros = 20;
                else if (mant_final[5]) leading_zeros = 21;
                else if (mant_final[4]) leading_zeros = 22;
                else if (mant_final[3]) leading_zeros = 23;
                else if (mant_final[2]) leading_zeros = 24;
                else if (mant_final[1]) leading_zeros = 25;
                else if (mant_final[0]) leading_zeros = 26;
                
                mant_final = mant_final << leading_zeros;
                
                // Adjust exponent and regime
                if (exp_final >= leading_zeros) begin
                    exp_final = exp_final - leading_zeros;
                end else begin
                    // Need to borrow from regime
                    k_final = k_final - ((leading_zeros - exp_final + 7) / 8);
                    exp_final = exp_final + 8 - (leading_zeros % 8);
                    if (exp_final >= 8) begin
                        exp_final = exp_final - 8;
                        k_final = k_final + 1;
                    end
                end
            end
        end
    end
end

/* ---------- Encode back to posit ---------- */
reg [31:0] p_next;
integer i, pos;
integer k_p;
integer exp_p;
reg [31:0] mag;

always @(*) begin
    p_next = POSIT32_ZERO;

    if (nar_a || nar_b)
        p_next = POSIT32_NAR;
    else if (zero_a && zero_b)
        p_next = POSIT32_ZERO;
    else if (zero_a)
        p_next = b_effective;
    else if (zero_b)
        p_next = a;
    else if (mant_final == 0)
        p_next = POSIT32_ZERO;
    else begin
        k_p   = k_final;
        exp_p = exp_final;

        if (k_p > MAX_K)
            p_next = sign_final ? POSIT32_NAR : 32'h7FFFFFFF;
        else if (k_p < MIN_K)
            p_next = POSIT32_ZERO;
        else begin
            mag = 32'b0;
            pos = 30;
            
            // Encode regime
            if (k_p >= 0) begin
                for (i = 0; i < k_p + 1 && pos >= 0; i = i + 1) begin
                    mag[pos] = 1'b1;
                    pos = pos - 1;
                end
                if (pos >= 0) begin
                    mag[pos] = 1'b0;
                    pos = pos - 1;
                end
            end else begin
                for (i = 0; i < -k_p && pos >= 0; i = i + 1) begin
                    mag[pos] = 1'b0;
                    pos = pos - 1;
                end
                if (pos >= 0) begin
                    mag[pos] = 1'b1;
                    pos = pos - 1;
                end
            end

            // Encode exponent (ES = 3 bits)
            for (i = 2; i >= 0 && pos >= 0; i = i - 1) begin
                mag[pos] = exp_p[i];
                pos = pos - 1;
            end

            // Encode fraction (mantissa without hidden bit)
            // Skip the hidden bit [26] and encode [25:0]
            for (i = 25; i >= 0 && pos >= 0; i = i - 1) begin
                mag[pos] = mant_final[i];
                pos = pos - 1;
            end

            // Fill remaining with 0
            while (pos >= 0) begin
                mag[pos] = 1'b0;
                pos = pos - 1;
            end

            p_next = sign_final ? (~mag + 1'b1) : mag;
        end
    end
end

/* ---------- Output ---------- */
always @(posedge clk) begin
    if (rst)
        p <= POSIT32_ZERO;
    else
        p <= p_next;
end

endmodule