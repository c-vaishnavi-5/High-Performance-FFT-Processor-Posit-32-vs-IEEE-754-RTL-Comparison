module tb_butterfly_unit;

    reg clk;
    reg rst;
    reg valid_in;
    reg [31:0] Ar, Ai, Br, Bi, Wr, Wi;
    wire valid_out;
    wire [31:0] Xr, Xi, Yr, Yi;
    
    posit_butterfly_unit_clk butterfly (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .Ar(Ar), .Ai(Ai),
        .Br(Br), .Bi(Bi),
        .Wr(Wr), .Wi(Wi),
        .valid_out(valid_out),
        .Xr(Xr), .Xi(Xi),
        .Yr(Yr), .Yi(Yi)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    task apply_butterfly_input;
        input [31:0] a_r, a_i, b_r, b_i, w_r, w_i;
        begin
            @(posedge clk);
            valid_in = 1'b1;
            Ar = a_r;
            Ai = a_i;
            Br = b_r;
            Bi = b_i;
            Wr = w_r;
            Wi = w_i;
            
            @(posedge clk);
            valid_in = 1'b0;
            
            // Wait for output (butterfly has 4 pipeline stages)
            #200; // Wait enough cycles for pipeline
        end
    endtask
    
    initial begin
        clk = 0;
        rst = 1;
        valid_in = 0;
        Ar = 32'b0; Ai = 32'b0;
        Br = 32'b0; Bi = 32'b0;
        Wr = 32'b0; Wi = 32'b0;
        
        $display("=== Testing Posit Butterfly Unit ===");
        
        // Reset
        #20;
        rst = 0;
        #20;
        
        // Test 1: Simple addition (W = 1 + 0j)
        // X = A + B*1 = A + B
        // Y = A - B*1 = A - B
        $display("\nTest 1: Simple addition/subtraction (W = 1)");
        $display("A = 1.0 + 0j, B = 1.0 + 0j, W = 1.0 + 0j");
        $display("Expected: X = 2.0 + 0j, Y = 0.0 + 0j");
        apply_butterfly_input(
            32'b01000000000000000000000000000000,  // A real: 1.0
            32'b00000000000000000000000000000000,  // A imag: 0.0
            32'b01000000000000000000000000000000,  // B real: 1.0
            32'b00000000000000000000000000000000,  // B imag: 0.0
            32'b01000000000000000000000000000000,  // W real: 1.0
            32'b00000000000000000000000000000000   // W imag: 0.0
        );
        
        $display("Results:");
        $display("X = %b + j%b", Xr, Xi);
        $display("Y = %b + j%b", Yr, Yi);
        $display("In hex:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #50;
        
        // Test 2: A = 1.0, B = 0.0 (should pass through)
        $display("\nTest 2: A = 1.0, B = 0.0 (W = 1)");
        $display("Expected: X = 1.0 + 0j, Y = 1.0 + 0j");
        apply_butterfly_input(
            32'b01000000000000000000000000000000,  // A: 1.0
            32'b00000000000000000000000000000000,
            32'b00000000000000000000000000000000,  // B: 0.0
            32'b00000000000000000000000000000000,
            32'b01000000000000000000000000000000,  // W: 1.0
            32'b00000000000000000000000000000000
        );
        
        $display("Results:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #50;
        
        // Test 3: A = 0.0, B = 1.0
        $display("\nTest 3: A = 0.0, B = 1.0 (W = 1)");
        $display("Expected: X = 1.0 + 0j, Y = -1.0 + 0j");
        apply_butterfly_input(
            32'b00000000000000000000000000000000,  // A: 0.0
            32'b00000000000000000000000000000000,
            32'b01000000000000000000000000000000,  // B: 1.0
            32'b00000000000000000000000000000000,
            32'b01000000000000000000000000000000,  // W: 1.0
            32'b00000000000000000000000000000000
        );
        
        $display("Results:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #50;
        
        // Test 4: Complex multiplication test
        // B = 1.0 + 0j, W = 0.707 - 0.707j (W^1)
        // B*W = (1.0)*(0.707 - 0.707j) = 0.707 - 0.707j
        $display("\nTest 4: Complex multiplication");
        $display("A = 0.0 + 0j, B = 1.0 + 0j, W = 0.707 - 0.707j");
        $display("B*W = 0.707 - 0.707j");
        $display("Expected: X = 0.707 - 0.707j, Y = -0.707 + 0.707j");
        apply_butterfly_input(
            32'b00000000000000000000000000000000,  // A: 0.0
            32'b00000000000000000000000000000000,
            32'b01000000000000000000000000000000,  // B: 1.0
            32'b00000000000000000000000000000000,
            32'b00111101101001111110111110011110,  // W real: 0.707
            32'b11000010010110000001000001100010   // W imag: -0.707
        );
        
        $display("Results:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #50;
        
        // Test 5: A = 1.0, B = 1.0, W = -1.0 (W^2)
        $display("\nTest 5: W = -1.0 (W^2)");
        $display("A = 1.0 + 0j, B = 1.0 + 0j, W = -1.0 + 0j");
        $display("B*W = -1.0 + 0j");
        $display("Expected: X = 0.0 + 0j, Y = 2.0 + 0j");
        apply_butterfly_input(
            32'b01000000000000000000000000000000,  // A: 1.0
            32'b00000000000000000000000000000000,
            32'b01000000000000000000000000000000,  // B: 1.0
            32'b00000000000000000000000000000000,
            32'b11000000000000000000000000000000,  // W real: -1.0
            32'b00000000000000000000000000000000   // W imag: 0.0
        );
        
        $display("Results:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #50;
        
        // Test 6: Test with imaginary parts
        $display("\nTest 6: Complex A and B (W = 1)");
        $display("A = 1.0 + 0.1j, B = 0.5 + 0.2j");
        apply_butterfly_input(
            32'b01000000000000000000000000000000,  // A real: 1.0
            32'b00110010011001100110011001100110,  // A imag: 0.1
            32'b00111111111111111111111111111111,  // B real: ~0.5 (use appropriate encoding)
            32'b00110000000000000000000000000000,  // B imag: ~0.2 (use appropriate encoding)
            32'b01000000000000000000000000000000,  // W: 1.0
            32'b00000000000000000000000000000000
        );
        
        $display("Results:");
        $display("X = %h + j%h", Xr, Xi);
        $display("Y = %h + j%h", Yr, Yi);
        
        #100;
        
        $display("\n=== Butterfly Tests Completed ===");
        $display("Check if:");
        $display("1. X = A + B*W");
        $display("2. Y = A - B*W");
        $display("3. Complex multiplication B*W is correct");
        $finish;
    end
    
    // Monitor pipeline stages
    initial begin
        #1;
        forever begin
            @(posedge clk);
            if (valid_in || valid_out) begin
                $display("Time=%0t: valid_in=%b, valid_out=%b", $time, valid_in, valid_out);
            end
        end
    end
    
endmodule
