module fp_Comp_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] A;
    reg [31:0] B;
    
    // Outputs
    wire res;
    
    // Instantiate the Unit Under Test (UUT)
    fp_Comp uut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .res(res)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        A = 32'h00000000;
        B = 32'h00000000;
        
        // Reset
        #10;
        reset = 0;
        
        // Test case 1: Different signs (A positive, B negative)
        A = 32'h3F800000; // 1.0
        B = 32'hBF800000; // -1.0
        #10;
        
        // Test case 2: Different signs (A negative, B positive)
        A = 32'hBF800000; // -1.0
        B = 32'h3F800000; // 1.0
        #10;
        
        // Test case 3: Same sign, different exponents (positive)
        A = 32'h40000000; // 2.0
        B = 32'h3F800000; // 1.0
        #10;
        
        // Test case 4: Same sign, different exponents (negative)
        A = 32'hC0000000; // -2.0
        B = 32'hBF800000; // -1.0
        #10;
        
        // Test case 5: Same sign, same exponent, different mantissa (positive)
        A = 32'h3F900000; // 1.125
        B = 32'h3F800000; // 1.0
        #10;
        
        // Test case 6: Same sign, same exponent, different mantissa (negative)
        A = 32'hBF900000; // -1.125
        B = 32'hBF800000; // -1.0
        #10;
        
        // Test case 7: Equal numbers
        A = 32'h3F800000; // 1.0
        B = 32'h3F800000; // 1.0
        #10;
        
        // Test case 8: Zero comparison
        A = 32'h00000000; // 0.0
        B = 32'h00000000; // 0.0
        #10;
        
        // Test case 9: Large numbers
        A = 32'h4F000000; // Large positive
        B = 32'h4E800000; // Smaller positive
        #10;
        
        // Test case 10: Reset test
        reset = 1;
        #10;
        reset = 0;
        $finish;
    end    
endmodule