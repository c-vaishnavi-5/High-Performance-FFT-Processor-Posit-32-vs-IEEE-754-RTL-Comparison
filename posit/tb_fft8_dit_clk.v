module tb_fft8_dit_clk;
    
    reg clk;
    reg rst;
    
    // Bit-reversed inputs
    reg [31:0] br0_r, br0_i, br1_r, br1_i;
    reg [31:0] br2_r, br2_i, br3_r, br3_i;
    reg [31:0] br4_r, br4_i, br5_r, br5_i;
    reg [31:0] br6_r, br6_i, br7_r, br7_i;
    
    // Outputs
    wire [31:0] Xr0, Xi0, Xr1, Xi1;
    wire [31:0] Xr2, Xi2, Xr3, Xi3;
    wire [31:0] Xr4, Xi4, Xr5, Xi5;
    wire [31:0] Xr6, Xi6, Xr7, Xi7;
    
    posit_fft8_dit_clk uut (
        .clk(clk),
        .rst(rst),
        .br0_r(br0_r), .br0_i(br0_i),
        .br1_r(br1_r), .br1_i(br1_i),
        .br2_r(br2_r), .br2_i(br2_i),
        .br3_r(br3_r), .br3_i(br3_i),
        .br4_r(br4_r), .br4_i(br4_i),
        .br5_r(br5_r), .br5_i(br5_i),
        .br6_r(br6_r), .br6_i(br6_i),
        .br7_r(br7_r), .br7_i(br7_i),
        .Xr0(Xr0), .Xi0(Xi0),
        .Xr1(Xr1), .Xi1(Xi1),
        .Xr2(Xr2), .Xi2(Xi2),
        .Xr3(Xr3), .Xi3(Xi3),
        .Xr4(Xr4), .Xi4(Xi4),
        .Xr5(Xr5), .Xi5(Xi5),
        .Xr6(Xr6), .Xi6(Xi6),
        .Xr7(Xr7), .Xi7(Xi7)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        
        br0_r = 32'b0; br0_i = 32'b0;
        br1_r = 32'b0; br1_i = 32'b0;
        br2_r = 32'b0; br2_i = 32'b0;
        br3_r = 32'b0; br3_i = 32'b0;
        br4_r = 32'b0; br4_i = 32'b0;
        br5_r = 32'b0; br5_i = 32'b0;
        br6_r = 32'b0; br6_i = 32'b0;
        br7_r = 32'b0; br7_i = 32'b0;
        
        $display("=== Posit FFT8 DIT Testbench ===");
        
        // Reset
        #20;
        rst = 0;
        #200; // Wait for pipeline
        
        // ================================================
        // Test 1: All zeros
        // ================================================
        $display("\nTest 1: All zeros");
        #400;
        $display("\n=== All Zeros Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 2: DC Signal (all ones in natural order)
        // ================================================
        $display("\nTest 2: DC Signal (all ones)");
        br0_r = 32'b01000000000000000000000000000000; // 1.0
        br1_r = 32'b01000000000000000000000000000000; // 1.0
        br2_r = 32'b01000000000000000000000000000000; // 1.0
        br3_r = 32'b01000000000000000000000000000000; // 1.0
        br4_r = 32'b01000000000000000000000000000000; // 1.0
        br5_r = 32'b01000000000000000000000000000000; // 1.0
        br6_r = 32'b01000000000000000000000000000000; // 1.0
        br7_r = 32'b01000000000000000000000000000000; // 1.0
        #400;
        $display("\n=== DC Signal Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 3: Impulse at natural x[0]
        // ================================================
        $display("\nTest 3: Impulse at x[0]");
        br0_r = 32'b01000000000000000000000000000000; // 1.0
        br1_r = 32'b0; br2_r = 32'b0; br3_r = 32'b0;
        br4_r = 32'b0; br5_r = 32'b0; br6_r = 32'b0; br7_r = 32'b0;
        // Clear imaginary parts
        br0_i = 32'b0; br1_i = 32'b0; br2_i = 32'b0; br3_i = 32'b0;
        br4_i = 32'b0; br5_i = 32'b0; br6_i = 32'b0; br7_i = 32'b0;
        #400;
        $display("\n=== Impulse Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 4: Alternating 1 and -1
        // ================================================
        $display("\nTest 4: Alternating 1 and -1");
        br0_r = 32'b01000000000000000000000000000000; // 1.0
        br1_r = 32'b01000000000000000000000000000000; // 1.0
        br2_r = 32'b01000000000000000000000000000000; // 1.0
        br3_r = 32'b01000000000000000000000000000000; // 1.0
        br4_r = 32'b11000000000000000000000000000000; // -1.0
        br5_r = 32'b11000000000000000000000000000000; // -1.0
        br6_r = 32'b11000000000000000000000000000000; // -1.0
        br7_r = 32'b11000000000000000000000000000000; // -1.0
        #400;
        $display("\n=== Alternating 1 and -1 Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 5: Cosine wave (frequency = 1)
        // ================================================
        $display("\nTest 5: Cosine Wave (freq=1)");
        br0_r = 32'b01000000000000000000000000000000;        // 1.0
        br1_r = 32'b11000000000000000000000000000000;        // -1.0
        br2_r = 32'b00000000000000000000000000000000;        // 0.0
        br3_r = 32'b00000000000000000000000000000000;        // 0.0
        br4_r = 32'b00111101101001111110111110011110;        // 0.707
        br5_r = 32'b11000010010110000001000001100010;        // -0.707
        br6_r = 32'b00000000000000000000000000000000;        // 0.0
        br7_r = 32'b00111101101001111110111110011110;        // 0.707
        // Clear imaginary parts
        br0_i = 32'b0; br1_i = 32'b0; br2_i = 32'b0; br3_i = 32'b0;
        br4_i = 32'b0; br5_i = 32'b0; br6_i = 32'b0; br7_i = 32'b0;
        #400;
        $display("\n=== Cosine Wave Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 6: Ramp signal
        // ================================================
        $display("\nTest 6: Ramp Signal");
        br0_r = 32'b00000000000000000000000000000000;        // 0.0
        br1_r = 32'b01001000000000000000000000000000;        // 4.0
        br2_r = 32'b01000100000000000000000000000000;        // 2.0
        br3_r = 32'b01001010000000000000000000000000;        // 6.0
        br4_r = 32'b01000000000000000000000000000000;        // 1.0
        br5_r = 32'b01001001000000000000000000000000;        // 5.0
        br6_r = 32'b01000110000000000000000000000000;        // 3.0
        br7_r = 32'b01001011000000000000000000000000;        // 7.0
        #400;
        $display("\n=== Ramp Signal Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 7: Small values (0.001)
        // ================================================
        $display("\nTest 7: Small Values (0.001)");
        br0_r = 32'b00011100000011000100100110111010;        // 0.001
        br1_r = 32'b00011100000011000100100110111010;        // 0.001
        br2_r = 32'b00011100000011000100100110111010;        // 0.001
        br3_r = 32'b00011100000011000100100110111010;        // 0.001
        br4_r = 32'b00011100000011000100100110111010;        // 0.001
        br5_r = 32'b00011100000011000100100110111010;        // 0.001
        br6_r = 32'b00011100000011000100100110111010;        // 0.001
        br7_r = 32'b00011100000011000100100110111010;        // 0.001
        // Clear imaginary parts
        br0_i = 32'b0; br1_i = 32'b0; br2_i = 32'b0; br3_i = 32'b0;
        br4_i = 32'b0; br5_i = 32'b0; br6_i = 32'b0; br7_i = 32'b0;
        #400;
        $display("\n=== Small Values Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 8: Complex inputs (1.0 + 0.1j)
        // ================================================
        $display("\nTest 8: Complex Inputs (1.0 + 0.1j)");
        br0_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br0_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br1_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br1_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br2_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br2_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br3_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br3_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br4_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br4_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br5_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br5_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br6_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br6_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        br7_r = 32'b01000000000000000000000000000000;        // 1.0 real
        br7_i = 32'b00110010011001100110011001100110;        // 0.1 imag
        #400;
        $display("\n=== Complex Inputs Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 9: Pure imaginary at x[0]
        // ================================================
        $display("\nTest 9: Pure Imaginary at x[0]");
        br0_r = 32'b00000000000000000000000000000000;        // 0.0 real
        br0_i = 32'b01000000000000000000000000000000;        // 1.0 imag
        br1_r = 32'b0; br1_i = 32'b0;
        br2_r = 32'b0; br2_i = 32'b0;
        br3_r = 32'b0; br3_i = 32'b0;
        br4_r = 32'b0; br4_i = 32'b0;
        br5_r = 32'b0; br5_i = 32'b0;
        br6_r = 32'b0; br6_i = 32'b0;
        br7_r = 32'b0; br7_i = 32'b0;
        #400;
        $display("\n=== Pure Imaginary Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        // ================================================
        // Test 10: All negative ones
        // ================================================
        $display("\nTest 10: All Negative Ones");
        br0_r = 32'b11000000000000000000000000000000;        // -1.0
        br1_r = 32'b11000000000000000000000000000000;        // -1.0
        br2_r = 32'b11000000000000000000000000000000;        // -1.0
        br3_r = 32'b11000000000000000000000000000000;        // -1.0
        br4_r = 32'b11000000000000000000000000000000;        // -1.0
        br5_r = 32'b11000000000000000000000000000000;        // -1.0
        br6_r = 32'b11000000000000000000000000000000;        // -1.0
        br7_r = 32'b11000000000000000000000000000000;        // -1.0
        // Clear imaginary parts
        br0_i = 32'b0; br1_i = 32'b0; br2_i = 32'b0; br3_i = 32'b0;
        br4_i = 32'b0; br5_i = 32'b0; br6_i = 32'b0; br7_i = 32'b0;
        #400;
        $display("\n=== All Negative Ones Test ===");
        $display("Time: %0t", $time);
        $display("X0: Real=%b, Imag=%b", Xr0, Xi0);
        $display("X1: Real=%b, Imag=%b", Xr1, Xi1);
        $display("X2: Real=%b, Imag=%b", Xr2, Xi2);
        $display("X3: Real=%b, Imag=%b", Xr3, Xi3);
        $display("X4: Real=%b, Imag=%b", Xr4, Xi4);
        $display("X5: Real=%b, Imag=%b", Xr5, Xi5);
        $display("X6: Real=%b, Imag=%b", Xr6, Xi6);
        $display("X7: Real=%b, Imag=%b", Xr7, Xi7);
        
        #100;
        $display("\n========== All Tests Completed ==========");
        $finish;
    end
    
endmodule