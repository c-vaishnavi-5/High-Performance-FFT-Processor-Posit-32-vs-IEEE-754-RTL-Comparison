// tb_posit_mult_exact.v
module tb_posit_mult_32bit;

reg clk;
reg rst;
reg [31:0] in_a;
reg [31:0] in_b;
wire [31:0] out;

/* DUT - Using your exact multiplier */
posit_mult_32bit dut (
    .clk(clk),
    .rst(rst),
    .a(in_a),
    .b(in_b),
    .p(out)
);

/* Clock */
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    in_a = 0;
    in_b = 0;
    #12;
    rst = 0;
end

initial begin
    #20;
    $display("=== Posit Multiplier Testbench (Your Exact Values) ===\n");
    
    // Wait a cycle after reset
    @(posedge clk);
    #1;
    
    // ========== BASIC TESTS ==========
    
    // Test 1: 1.0 * 1.0 = 1.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    @(posedge clk);
    #1;
    $display("Test 1: 1.0 * 1.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 2: 0.0 * 1.0 = 0.0
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    @(posedge clk);
    #1;
    $display("Test 2: 0.0 * 1.0 = 0.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 00000000000000000000000000000000\n");
    
    // Test 3: 2.0 * 1.0 = 2.0
    in_a = 32'b01000100000000000000000000000000;  // 2.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    @(posedge clk);
    #1;
    $display("Test 3: 2.0 * 1.0 = 2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000100000000000000000000000000\n");
    
    // Test 4: 2.0 * 2.0 = 4.0
    in_a = 32'b01000100000000000000000000000000;  // 2.0
    in_b = 32'b01000100000000000000000000000000;  // 2.0
    @(posedge clk);
    #1;
    $display("Test 4: 2.0 * 2.0 = 4.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01001000000000000000000000000000\n");
    
    // Test 5: 4.0 * 2.0 = 8.0
    in_a = 32'b01001000000000000000000000000000;  // 4.0
    in_b = 32'b01000100000000000000000000000000;  // 2.0
    @(posedge clk);
    #1;
    $display("Test 5: 4.0 * 2.0 = 8.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01001100000000000000000000000000\n");
    
    // Test 6: 0.5 * 0.5 = 0.25
    in_a = 32'b00111100000000000000000000000000;  // 0.5
    in_b = 32'b00111100000000000000000000000000;  // 0.5
    @(posedge clk);
    #1;
    $display("Test 6: 0.5 * 0.5 = 0.25");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 00111000000000000000000000000000\n");
    
    // Test 7: 1.0 * -1.0 = -1.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    @(posedge clk);
    #1;
    $display("Test 7: 1.0 * -1.0 = -1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 11000000000000000000000000000000\n");
    
    // Test 8: -1.0 * -1.0 = 1.0
    in_a = 32'b11000000000000000000000000000000;  // -1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    @(posedge clk);
    #1;
    $display("Test 8: -1.0 * -1.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // ========== INTERMEDIATE TESTS ==========
    
    // Test 9: 8.0 * 8.0 = 64.0
    in_a = 32'b01001100000000000000000000000000;  // 8.0
    in_b = 32'b01001100000000000000000000000000;  // 8.0
    @(posedge clk);
    #1;
    $display("Test 9: 8.0 * 8.0 = 64.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01011000000000000000000000000000\n");
    
    // Test 10: 0.25 * 4.0 = 1.0
    in_a = 32'b00111000000000000000000000000000;  // 0.25
    in_b = 32'b01001000000000000000000000000000;  // 4.0
    @(posedge clk);
    #1;
    $display("Test 10: 0.25 * 4.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // ========== FRACTION TESTS ==========
    
    // Test 11: 1.25 * 1.5 = 1.875
    in_a = 32'b01000001000000000000000000000000;  // 1.25
    in_b = 32'b01000010000000000000000000000000;  // 1.5
    @(posedge clk);
    #1;
    $display("Test 11: 1.25 * 1.5 = 1.875");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000011100000000000000000000000\n");
    
    // Test 12: 0.75 * 2.0 = 1.5
    in_a = 32'b00111110000000000000000000000000;  // 0.75
    in_b = 32'b01000100000000000000000000000000;  // 2.0
    @(posedge clk);
    #1;
    $display("Test 12: 0.75 * 2.0 = 1.5");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000010000000000000000000000000\n");
    
    // Test 13: 1.333333 * 1.5 = 2.0
    in_a = 32'b01000001010101010101010100111111;  // 1.333333
    in_b = 32'b01000010000000000000000000000000;  // 1.5
    @(posedge clk);
    #1;
    $display("Test 13: 1.333333 * 1.5 = 2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01000011111111111111111111011110\n");
    
    // ========== LARGE VALUE TESTS ==========
    
    // Test 14: 64.0 * 64.0 = 4096.0
    in_a = 32'b01011000000000000000000000000000;  // 64.0
    in_b = 32'b01011000000000000000000000000000;  // 64.0
    @(posedge clk);
    #1;
    $display("Test 14: 64.0 * 64.0 = 4096.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 01101000000000000000000000000000\n");
    
    // ========== SMALL VALUE TESTS ==========
    
    // Test 15: 0.00390625 * 0.00390625 = 0.0000152588
    in_a = 32'b00100000000000000000000000000000;  // 0.00390625
    in_b = 32'b00100000000000000000000000000000;  // 0.00390625
    @(posedge clk);
    #1;
    $display("Test 15: 0.00390625 * 0.00390625");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 00010000000000000000000000011000\n");
    
    // ========== SPECIAL CASE TESTS ==========
    
    // Test 16: NaN * 1.0 = NaN
    // Assuming NaN is 0x80000000
    in_a = 32'b10000000000000000000000000000000;  // NaN
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    @(posedge clk);
    #1;
    $display("Test 16: NaN * 1.0 = NaN");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    // Test 17: 0.0 * NaN = NaN
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b10000000000000000000000000000000;  // NaN
    @(posedge clk);
    #1;
    $display("Test 17: 0.0 * NaN = NaN");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    // Test 18: Zero multiplication edge case
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b01001100000000000000000000000000;  // 8.0
    @(posedge clk);
    #1;
    $display("Test 18: 0.0 * 8.0 = 0.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Output   : %32b", out);
    $display("Expected : 00000000000000000000000000000000\n");
    
    $display("=== All Tests Complete ===");
    $finish;
end

endmodule