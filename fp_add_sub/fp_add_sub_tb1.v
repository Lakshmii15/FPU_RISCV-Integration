module fp_add_sub_tb();

    reg clk;
    reg reset;
    reg [31:0] A, B;
    reg add_sub;
    wire [31:0] result;

    // Instantiate the module
    fp_add_sub dut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .op(add_sub),
        .Result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize
        reset = 1;
        A = 32'b0;
        B = 32'b0;
        add_sub = 1;

        #10 reset = 0;

        // Test Case 1: 0.3 + 0.06
        // 0.3 ≈ 0x3E99999A
        // 0.06 ≈ 0x3D4CCCCD
        A = 32'h3E99999A;
        B = 32'h3D4CCCCD;
        add_sub = 0; // Add (corrected: 0 for add)
        $monitor("Time=%t, A=%h, B=%h, op=%b, Result=%h", $time, A, B, add_sub, result);
        #20;

        // Test Case 2: 0.3 - 0.06
        add_sub = 1; // Subtract
        #20;
        $finish;
    end
endmodule