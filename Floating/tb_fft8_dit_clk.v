module tb_fft8_dit_clk;
    
    reg clk;
    reg rst_n;
    
    reg valid_in;
    reg [31:0] br0_r, br0_i, br1_r, br1_i;
    reg [31:0] br2_r, br2_i, br3_r, br3_i;
    reg [31:0] br4_r, br4_i, br5_r, br5_i;
    reg [31:0] br6_r, br6_i, br7_r, br7_i;
    
    wire valid_out;
    wire [31:0] Xr0, Xi0, Xr1, Xi1;
    wire [31:0] Xr2, Xi2, Xr3, Xi3;
    wire [31:0] Xr4, Xi4, Xr5, Xi5;
    wire [31:0] Xr6, Xi6, Xr7, Xi7;
    
    fft8_dit_clk uut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .br0_r(br0_r), .br0_i(br0_i),
        .br1_r(br1_r), .br1_i(br1_i),
        .br2_r(br2_r), .br2_i(br2_i),
        .br3_r(br3_r), .br3_i(br3_i),
        .br4_r(br4_r), .br4_i(br4_i),
        .br5_r(br5_r), .br5_i(br5_i),
        .br6_r(br6_r), .br6_i(br6_i),
        .br7_r(br7_r), .br7_i(br7_i),
        .valid_out(valid_out),
        .Xr0(Xr0), .Xi0(Xi0),
        .Xr1(Xr1), .Xi1(Xi1),
        .Xr2(Xr2), .Xi2(Xi2),
        .Xr3(Xr3), .Xi3(Xi3),
        .Xr4(Xr4), .Xi4(Xi4),
        .Xr5(Xr5), .Xi5(Xi5),
        .Xr6(Xr6), .Xi6(Xi6),
        .Xr7(Xr7), .Xi7(Xi7)
    );
    
    always #5 clk = ~clk;
    
    function real fp_to_real;
        input [31:0] fp;
        real mantissa;
        integer exp;
        reg sign;
        begin
            sign = fp[31];
            exp = fp[30:23] - 127;
            mantissa = 1.0 + (fp[22:0] / 8388608.0); // 2^23
            
            if (fp[30:23] == 8'h00)
                fp_to_real = 0.0;
            else if (fp[30:23] == 8'hFF)
                fp_to_real = (sign) ? -999999.0 : 999999.0;
            else
                fp_to_real = (sign ? -1.0 : 1.0) * mantissa * (2.0 ** exp);
        end
    endfunction    
    task apply_fft_input_natural;
        input [31:0] in0_r, in0_i, in1_r, in1_i;  // Natural order indices
        input [31:0] in2_r, in2_i, in3_r, in3_i;
        input [31:0] in4_r, in4_i, in5_r, in5_i;
        input [31:0] in6_r, in6_i, in7_r, in7_i;
        begin
            @(posedge clk);
            valid_in = 1'b1;
            // Map natural order to bit-reversed order
            br0_r = in0_r; br0_i = in0_i;  // 0 (000) -> 0 (000)
            br1_r = in4_r; br1_i = in4_i;  // 4 (100) -> 1 (001)
            br2_r = in2_r; br2_i = in2_i;  // 2 (010) -> 2 (010)
            br3_r = in6_r; br3_i = in6_i;  // 6 (110) -> 3 (011)
            br4_r = in1_r; br4_i = in1_i;  // 1 (001) -> 4 (100)
            br5_r = in5_r; br5_i = in5_i;  // 5 (101) -> 5 (101)
            br6_r = in3_r; br6_i = in3_i;  // 3 (011) -> 6 (110)
            br7_r = in7_r; br7_i = in7_i;  // 7 (111) -> 7 (111)
            
            @(posedge clk);
            valid_in = 1'b0;
            wait(valid_out == 1'b1);
            @(posedge clk);
        end
    endtask
    
    task display_results;
        input [80*8:1] test_name;
        begin
            $display("\n=== %s ===", test_name);
            $display("Time: %0t", $time);
            $display("Output[0]: Real=%f, Imag=%f", fp_to_real(Xr0), fp_to_real(Xi0));
            $display("Output[1]: Real=%f, Imag=%f", fp_to_real(Xr1), fp_to_real(Xi1));
            $display("Output[2]: Real=%f, Imag=%f", fp_to_real(Xr2), fp_to_real(Xi2));
            $display("Output[3]: Real=%f, Imag=%f", fp_to_real(Xr3), fp_to_real(Xi3));
            $display("Output[4]: Real=%f, Imag=%f", fp_to_real(Xr4), fp_to_real(Xi4));
            $display("Output[5]: Real=%f, Imag=%f", fp_to_real(Xr5), fp_to_real(Xi5));
            $display("Output[6]: Real=%f, Imag=%f", fp_to_real(Xr6), fp_to_real(Xi6));
            $display("Output[7]: Real=%f, Imag=%f", fp_to_real(Xr7), fp_to_real(Xi7));
        end
    endtask
    initial begin
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        
        br0_r = 32'h0; br0_i = 32'h0;
        br1_r = 32'h0; br1_i = 32'h0;
        br2_r = 32'h0; br2_i = 32'h0;
        br3_r = 32'h0; br3_i = 32'h0;
        br4_r = 32'h0; br4_i = 32'h0;
        br5_r = 32'h0; br5_i = 32'h0;
        br6_r = 32'h0; br6_i = 32'h0;
        br7_r = 32'h0; br7_i = 32'h0;
        
        // Reset sequence
        #20;
        rst_n = 1;
        #20;

        apply_fft_input_natural(
            32'h3F800000, 32'h00000000,  // x[0]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[1]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[2]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[3]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[4]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[5]: 1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[6]: 1.0 + 0j
            32'h3F800000, 32'h00000000   // x[7]: 1.0 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3F800000, 32'h00000000,  // x[0]: 1.0 + 0j
            32'h00000000, 32'h00000000,  // x[1]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[2]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[3]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[4]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[5]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[6]: 0.0 + 0j
            32'h00000000, 32'h00000000   // x[7]: 0.0 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3F800000, 32'h00000000,  // x[0]:  1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[1]: -1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[2]:  1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[3]: -1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[4]:  1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[5]: -1.0 + 0j
            32'h3F800000, 32'h00000000,  // x[6]:  1.0 + 0j
            32'hBF800000, 32'h00000000   // x[7]: -1.0 + 0j
        );
        
        #50;

        apply_fft_input_natural(
            32'h3F800000, 32'h00000000,  // x[0]:  1.0 + 0j
            32'h3F3504F3, 32'h00000000,  // x[1]:  0.707 + 0j
            32'h00000000, 32'h00000000,  // x[2]:  0.0 + 0j
            32'hBF3504F3, 32'h00000000,  // x[3]: -0.707 + 0j
            32'hBF800000, 32'h00000000,  // x[4]: -1.0 + 0j
            32'hBF3504F3, 32'h00000000,  // x[5]: -0.707 + 0j
            32'h00000000, 32'h00000000,  // x[6]:  0.0 + 0j
            32'h3F3504F3, 32'h00000000   // x[7]:  0.707 + 0j
        );
        #50;
        
        apply_fft_input_natural(
            32'h00000000, 32'h00000000,  // x[0]: 0.0 + 0j
            32'h3F800000, 32'h00000000,  // x[1]: 1.0 + 0j
            32'h40000000, 32'h00000000,  // x[2]: 2.0 + 0j
            32'h40400000, 32'h00000000,  // x[3]: 3.0 + 0j
            32'h40800000, 32'h00000000,  // x[4]: 4.0 + 0j
            32'h40A00000, 32'h00000000,  // x[5]: 5.0 + 0j
            32'h40C00000, 32'h00000000,  // x[6]: 6.0 + 0j
            32'h40E00000, 32'h00000000   // x[7]: 7.0 + 0j
        );
        
        #50;
        apply_fft_input_natural(
            32'h3A83126F, 32'h00000000,  // x[0]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[1]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[2]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[3]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[4]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[5]: 0.001 + 0j
            32'h3A83126F, 32'h00000000,  // x[6]: 0.001 + 0j
            32'h3A83126F, 32'h00000000   // x[7]: 0.001 + 0j
        );
        
        #50;
        apply_fft_input_natural(
            32'h42C80000, 32'h00000000,  // x[0]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[1]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[2]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[3]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[4]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[5]: 100.0 + 0j
            32'h42C80000, 32'h00000000,  // x[6]: 100.0 + 0j
            32'h42C80000, 32'h00000000   // x[7]: 100.0 + 0j
        );
        #50;
        
        apply_fft_input_natural(
            32'h3F666666, 32'h00000000,  // x[0]:  0.9 + 0j
            32'hBF4CCCCD, 32'h00000000,  // x[1]: -0.8 + 0j
            32'h3F333333, 32'h00000000,  // x[2]:  0.7 + 0j
            32'hBF8CCCCD, 32'h00000000,  // x[3]: -1.1 + 0j
            32'h3F999999, 32'h00000000,  // x[4]:  1.2 + 0j
            32'hBF733333, 32'h00000000,  // x[5]: -0.95 + 0j
            32'h3F59999A, 32'h00000000,  // x[6]:  0.85 + 0j
            32'hBF400000, 32'h00000000   // x[7]: -0.75 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3DCCCCCD, 32'h00000000,  // x[0]: 0.1 + 0j
            32'h3E4CCCCD, 32'h00000000,  // x[1]: 0.2 + 0j
            32'h3E99999A, 32'h00000000,  // x[2]: 0.3 + 0j
            32'h3ECCCCCD, 32'h00000000,  // x[3]: 0.4 + 0j
            32'h3F000000, 32'h00000000,  // x[4]: 0.5 + 0j
            32'h3F19999A, 32'h00000000,  // x[5]: 0.6 + 0j
            32'h3F333333, 32'h00000000,  // x[6]: 0.7 + 0j
            32'h3F4CCCCD, 32'h00000000   // x[7]: 0.8 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3F800000, 32'h3DCCCCCD,  // x[0]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[1]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[2]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[3]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[4]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[5]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD,  // x[6]: 1.0 + 0.1j
            32'h3F800000, 32'h3DCCCCCD   // x[7]: 1.0 + 0.1j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3C23D70A, 32'h00000000,  // x[0]:  0.01 + 0j
            32'hBC23D70A, 32'h00000000,  // x[1]: -0.01 + 0j
            32'h3C23D70A, 32'h00000000,  // x[2]:  0.01 + 0j
            32'hBC23D70A, 32'h00000000,  // x[3]: -0.01 + 0j
            32'h3C23D70A, 32'h00000000,  // x[4]:  0.01 + 0j
            32'hBC23D70A, 32'h00000000,  // x[5]: -0.01 + 0j
            32'h3C23D70A, 32'h00000000,  // x[6]:  0.01 + 0j
            32'hBC23D70A, 32'h00000000   // x[7]: -0.01 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h00000000, 32'h3F800000,  // x[0]: 0.0 + 1.0j
            32'h00000000, 32'h00000000,  // x[1]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[2]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[3]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[4]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[5]: 0.0 + 0j
            32'h00000000, 32'h00000000,  // x[6]: 0.0 + 0j
            32'h00000000, 32'h00000000   // x[7]: 0.0 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h2EDBE6FF, 32'h00000000,  // x[0]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[1]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[2]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[3]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[4]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[5]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000,  // x[6]: ~1e-10 + 0j
            32'h2EDBE6FF, 32'h00000000   // x[7]: ~1e-10 + 0j
        );
        
        #50;
        
        apply_fft_input_natural(
            32'h3F000000, 32'h00000000,  // x[0]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[1]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[2]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[3]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[4]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[5]: 0.5 + 0j
            32'h3F000000, 32'h00000000,  // x[6]: 0.5 + 0j
            32'h3F000000, 32'h00000000   // x[7]: 0.5 + 0j
        );
        display_results("Half Values Test");
        
        #50;
        apply_fft_input_natural(
            32'hBF800000, 32'h00000000,  // x[0]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[1]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[2]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[3]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[4]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[5]: -1.0 + 0j
            32'hBF800000, 32'h00000000,  // x[6]: -1.0 + 0j
            32'hBF800000, 32'h00000000   // x[7]: -1.0 + 0j
        );
        
        #100;
        
        $finish;
    end    
endmodule