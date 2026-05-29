module tb_posit_addsub_32bit;

reg clk;
reg rst;
reg [31:0] in_a;
reg [31:0] in_b;
reg op;      // 0: add, 1: subtract
wire [31:0] out;

/* DUT */
posit_addsub_32bit dut (
    .clk(clk),
    .rst(rst),
    .a(in_a),
    .b(in_b),
    .op(op),
    .p(out)
);

/* Clock */
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    in_a = 0;
    in_b = 0;
    op = 0;
    #12;
    rst = 0;
end

initial begin
    #20;
    $display("=== Posit Add/Sub Testbench (ES=3) ===\n");
    
    // Wait a cycle after reset
    @(posedge clk);
    #1;
    
    // ========== ZERO TESTS ==========
    
    // Test 1: 0.0 + 0.0 = 0.0
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b00000000000000000000000000000000;  // 0.0
    op = 0;  // add
    @(posedge clk);
    #1;
    $display("Test 1: 0.0 + 0.0 = 0.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 00000000000000000000000000000000\n");
    
    // Test 2: 0.0 + 1.0 = 1.0
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 2: 0.0 + 1.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 3: 1.0 + 0.0 = 1.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b00000000000000000000000000000000;  // 0.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 3: 1.0 + 0.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 4: 1.0 - 0.0 = 1.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b00000000000000000000000000000000;  // 0.0
    op = 1;  // subtract
    @(posedge clk);
    #1;
    $display("Test 4: 1.0 - 0.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 5: 0.0 - 1.0 = -1.0
    in_a = 32'b00000000000000000000000000000000;  // 0.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 5: 0.0 - 1.0 = -1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 11000000000000000000000000000000\n");
    
    // ========== BASIC ADDITION TESTS ==========
    
    // Test 6: 1.0 + 1.0 = 2.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 6: 1.0 + 1.0 = 2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000100000000000000000000000000\n");
    
    // Test 7: 2.0 + 1.0 = 3.0
    in_a = 32'b01000100000000000000000000000000;  // 2.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 7: 2.0 + 1.0 = 3.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000110000000000000000000000000\n");
    
    // Test 8: 3.0 + 2.0 = 5.0
    in_a = 32'b01000110000000000000000000000000;  // 3.0
    in_b = 32'b01000100000000000000000000000000;  // 2.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 8: 3.0 + 2.0 = 5.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01001001000000000000000000000000\n");
    
    // Test 9: 4.0 + 1.0 = 5.0
    in_a = 32'b01001000000000000000000000000000;  // 4.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 9: 4.0 + 1.0 = 5.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01001001000000000000000000000000\n");
    
    // Test 10: 0.5 + 0.5 = 1.0
    in_a = 32'b00111100000000000000000000000000;  // 0.5
    in_b = 32'b00111100000000000000000000000000;  // 0.5
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 10: 0.5 + 0.5 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 11: 0.25 + 0.25 = 0.5
    in_a = 32'b00111000000000000000000000000000;  // 0.25
    in_b = 32'b00111000000000000000000000000000;  // 0.25
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 11: 0.25 + 0.25 = 0.5");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 00111100000000000000000000000000\n");
    
    // Test 12: 0.125 + 0.125 = 0.25
    in_a = 32'b00110100000000000000000000000000;  // 0.125
    in_b = 32'b00110100000000000000000000000000;  // 0.125
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 12: 0.125 + 0.125 = 0.25");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 00111000000000000000000000000000\n");
    
    // ========== BASIC SUBTRACTION TESTS ==========
    
    // Test 13: 2.0 - 1.0 = 1.0
    in_a = 32'b01000100000000000000000000000000;  // 2.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 13: 2.0 - 1.0 = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 14: 3.0 - 1.0 = 2.0
    in_a = 32'b01000110000000000000000000000000;  // 3.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 14: 3.0 - 1.0 = 2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01000100000000000000000000000000\n");
    
    // Test 15: 5.0 - 2.0 = 3.0
    in_a = 32'b01001001000000000000000000000000;  // 5.0
    in_b = 32'b01000100000000000000000000000000;  // 2.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 15: 5.0 - 2.0 = 3.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01000110000000000000000000000000\n");
    
    // Test 16: 5.0 - 1.0 = 4.0
    in_a = 32'b01001001000000000000000000000000;  // 5.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 16: 5.0 - 1.0 = 4.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01001000000000000000000000000000\n");
    
    // Test 17: 1.0 - 0.5 = 0.5
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b00111100000000000000000000000000;  // 0.5
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 17: 1.0 - 0.5 = 0.5");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 00111100000000000000000000000000\n");
    
    // Test 18: 0.5 - 0.25 = 0.25
    in_a = 32'b00111100000000000000000000000000;  // 0.5
    in_b = 32'b00111000000000000000000000000000;  // 0.25
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 18: 0.5 - 0.25 = 0.25");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 00111000000000000000000000000000\n");
    
    // ========== NEGATIVE VALUE TESTS ==========
    
    // Test 19: 1.0 + (-1.0) = 0.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 19: 1.0 + (-1.0) = 0.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 00000000000000000000000000000000\n");
    
    // Test 20: (-1.0) + (-1.0) = -2.0
    in_a = 32'b11000000000000000000000000000000;  // -1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 20: (-1.0) + (-1.0) = -2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 10111100000000000000000000000000\n");
    
    // Test 21: 1.0 - (-1.0) = 2.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 21: 1.0 - (-1.0) = 2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 01000100000000000000000000000000\n");
    
    // Test 22: (-1.0) - 1.0 = -2.0
    in_a = 32'b11000000000000000000000000000000;  // -1.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 22: (-1.0) - 1.0 = -2.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 10111100000000000000000000000000\n");
    
    // Test 23: (-1.0) - (-1.0) = 0.0
    in_a = 32'b11000000000000000000000000000000;  // -1.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 23: (-1.0) - (-1.0) = 0.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 00000000000000000000000000000000\n");
    
    // ========== MIXED SIGN TESTS ==========
    
    // Test 24: 2.0 + (-1.0) = 1.0
    in_a = 32'b01000100000000000000000000000000;  // 2.0
    in_b = 32'b11000000000000000000000000000000;  // -1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 24: 2.0 + (-1.0) = 1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01000000000000000000000000000000\n");
    
    // Test 25: (-2.0) + 1.0 = -1.0
    in_a = 32'b10111100000000000000000000000000;  // -2.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 25: (-2.0) + 1.0 = -1.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 11000000000000000000000000000000\n");
    
    // ========== ALIGNMENT TESTS (Large + Small) ==========
    
    // Test 26: 16.0 + 1.0 = 17.0
    in_a = 32'b01010000000000000000000000000000;  // 16.0
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 26: 16.0 + 1.0 = 17.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01010000010000000000000000000000\n");
    
    // Test 27: 1.0 + 16.0 = 17.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b01010000000000000000000000000000;  // 16.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 27: 1.0 + 16.0 = 17.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01010000010000000000000000000000\n");
    
    // Test 28: 8.0 + 0.125 = 8.125
    in_a = 32'b01001100000000000000000000000000;  // 8.0
    in_b = 32'b00110100000000000000000000000000;  // 0.125
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 28: 8.0 + 0.125 = 8.125");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01001100000100000000000000000000\n");
    
    // Test 29: 0.125 + 8.0 = 8.125
    in_a = 32'b00110100000000000000000000000000;  // 0.125
    in_b = 32'b01001100000000000000000000000000;  // 8.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 29: 0.125 + 8.0 = 8.125");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 01001100000100000000000000000000\n");
    
    // ========== ALIGNMENT TESTS (Small - Large) ==========
    
    // Test 30: 1.0 - 16.0 = -15.0
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b01010000000000000000000000000000;  // 16.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 30: 1.0 - 16.0 = -15.0");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 10110000100000000000000000000000\n");
    
    // Test 31: 0.125 - 8.0 = -7.875
    in_a = 32'b00110100000000000000000000000000;  // 0.125
    in_b = 32'b01001100000000000000000000000000;  // 8.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 31: 0.125 - 8.0 = -7.875");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 10110100001000000000000000000000\n");
    
    // ========== SPECIAL CASES TESTS ==========
    
    // Test 32: NaR + 1.0 = NaR
    in_a = 32'b10000000000000000000000000000000;  // NaR
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 32: NaR + 1.0 = NaR");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    // Test 33: 1.0 + NaR = NaR
    in_a = 32'b01000000000000000000000000000000;  // 1.0
    in_b = 32'b10000000000000000000000000000000;  // NaR
    op = 0;
    @(posedge clk);
    #1;
    $display("Test 33: 1.0 + NaR = NaR");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Add");
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    // Test 34: NaR - 1.0 = NaR
    in_a = 32'b10000000000000000000000000000000;  // NaR
    in_b = 32'b01000000000000000000000000000000;  // 1.0
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 34: NaR - 1.0 = NaR");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    // Test 35: NaR - NaR = NaR
    in_a = 32'b10000000000000000000000000000000;  // NaR
    in_b = 32'b10000000000000000000000000000000;  // NaR
    op = 1;
    @(posedge clk);
    #1;
    $display("Test 35: NaR - NaR = NaR");
    $display("A        : %32b", in_a);
    $display("B        : %32b", in_b);
    $display("Operation: Subtract");
    $display("Output   : %32b", out);
    $display("Expected : 10000000000000000000000000000000\n");
    
    $display("=== All Tests Complete ===");
    $finish;
end

endmodule