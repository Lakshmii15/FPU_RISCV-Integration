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

        // Test Case 1: 0.25 + 0.5
        // 0.25 ≈ 0x3E800000
        // 0.5 ≈ 0x3F000000
        A = 32'h3E800000;
        B = 32'h3F000000;
        add_sub = 0; // Add
        $monitor("Time=%t, A=%h, B=%h, op=%b, Result=%h", $time, A, B, add_sub, result);
        #20;

        // Test Case 2: 0.25 - 0.5
        add_sub = 1; // Subtract
        #20;
        $finish;
    end
endmodule