module fp_comp_tb;
    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    
    // Outputs
    wire equal;
    wire less;
    wire greater;
    
    // Instantiate the Unit Under Test (UUT)
    fp_comp uut (
        .A(A),
        .B(B),
        .equal(equal),
        .less(less),
        .greater(greater)
    );
    
    // Test procedure
    initial begin
        // Initialize Inputs
        A = 32'h0;
        B = 32'h0;
        
        // Wait for global reset
        #10;
        
        // Test Case 1: Both zeros
        $display("Test 1: A = 0, B = 0");
        A = 32'h00000000; // +0
        B = 32'h00000000; // +0
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 2: Positive numbers (```(A = 1.5, B = 1.5)
        $display("Test 2: A = 1.5, B = 1.5");
        A = 32'h3FC00000; // 1.5
        B = 32'h3FC00000; // 1.5
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 3: Positive vs Negative (A = 1.5, B = -1.5)
        $display("Test 3: A = 1.5, B = -1.5");
        A = 32'h3FC00000; // 1.5
        B = 32'hBFC00000; // -1.5
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 4: Negative numbers (A = -2.0, B = -1.0)
        $display("Test 4: A = -2.0, B = -1.0");
        A = 32'hC0000000; // -2.0
        B = 32'hBF800000; // -1.0
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 5: Infinity cases (A = +Inf, B = +Inf)
        $display("Test 5: A = +Inf, B = +Inf");
        A = 32'h7F800000; // +Inf
        B = 32'h7F800000; // +Inf
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 6: Infinity vs number (A = +Inf, B = 1.5)
        $display("Test 6: A = +Inf, B = 1.5");
        A = 32'h7F800000; // +Inf
        B = 32'h3FC00000; // 1.5
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 7: NaN cases (A = NaN, B = 1.5)
        $display("Test 7: A = NaN, B = 1.5");
        A = 32'h7FC00001; // NaN
        B = 32'h3FC00000; // 1.5
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 8: Both NaN
        $display("Test 8: A = NaN, B = NaN");
        A = 32'h7FC00001; // NaN
        B = 32'h7FC00002; // NaN
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 9: Small positive numbers (A = 0.1, B = 0.2)
        $display("Test 9: A = 0.1, B = 0.2");
        A = 32'h3DCCCCCD; // ~0.1
        B = 32'h3E4CCCCD; // ~0.2
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Test Case 10: Same exponent, different mantissa (A = 1.25, B = 1.5)
        $display("Test 10: A = 1.25, B = 1.5");
        A = 32'h3FA00000; // 1.25
        B = 32'h3FC00000; // 1.5
        #10;
        $display("A=%h, B=%h, equal=%b, less=%b, greater=%b", A, B, equal, less, greater);
        
        // Finish simulation
        $display("Simulation completed.");
        $finish;
    end
endmodule