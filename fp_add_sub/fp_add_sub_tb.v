module fp_add_sub_tb;
    // Inputs
    reg clk;
    reg reset;
    reg [31:0] A;
    reg [31:0] B;
    reg op;
    
    // Outputs
    wire [31:0] result;
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    // Instantiate the Unit Under Test (UUT)
    fp_add_sub uut (.clk(clk), .reset(reset),
        .A(A),
        .B(B),
        .op(op),
        .result(result)
    );
    
    // Test procedure
    initial begin
        // Initialize Inputs
        reset = 1'b1;
        A = 32'h0;
        B = 32'h0;
        op = 1'b0;
        
        // Wait for global reset
        #100;
        reset = 1'b0;
        // Test Case 1: Normal addition (2.5 + 3.5 = 6.0)
        A = 32'h40200000; // 2.5
        B = 32'h40600000; // 3.5
        op = 1'b0; // Addition
        #10;
                
        // Test Case 2: Normal subtraction (3.5 - 2.5 = 1.0)
        A = 32'h40600000; // 3.5
        B = 32'h40200000; // 2.5
        op = 1'b1; // Subtraction
        #10;
        
        // Test Case 3: Zero + Zero
        A = 32'h00000000; // 0.0
        B = 32'h00000000; // 0.0
        op = 1'b0; // Addition
        #10;
        
        // Test Case 4: Infinity + Normal
        A = 32'h7F800000; // +Infinity
        B = 32'h40400000; // 3.0
        op = 1'b0; // Addition
        #10;
        
        // Test Case 5: NaN + Normal
        A = 32'h7FC00001; // NaN
        B = 32'h40400000; // 3.0
        op = 1'b0; // Addition
        #10;
        
        // Test Case 6: Infinity - Infinity (same sign)
        A = 32'h7F800000; // +Infinity
        B = 32'h7F800000; // +Infinity
        op = 1'b1; // Subtraction
        #10;
        
        // Test Case 7: Negative + Positive
        A = 32'hC0000000; // -2.0
        B = 32'h40400000; // 3.0
        op = 1'b0; // Addition
        #10;
        
        // Test Case 8: Small number + Large number
        A = 32'h3F800000; // 1.0
        B = 32'h4B800000; // Large number
        op = 1'b0; // Addition
        #10;
       
        // Test Case 9: Subtraction resulting in zero
        A= 32'h40000000; // 2.0
        B = 32'h40000000; // 2.0
        op = 1'b1; // Subtraction
        #10;
                
        // Test Case 10: Denormalized number
        A = 32'h00000001; // Denormalized
        B = 32'h3F800000; // 1.0
        op = 1'b0; // Addition
        #10;
                
        // Finish simulation
        #100;
        $finish;
    end
endmodule