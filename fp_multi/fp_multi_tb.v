module fp_multi_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg [31:0] A;
    reg [31:0] B;
    wire [31:0] Result;

    // Instantiate the floating-point multiplier
    fp_multi dut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .Result(Result)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        A = 32'b0;
        B = 32'b0;

        // Apply reset
        #10;
        reset = 0;

        // Test case 1: 2.5 * 3.0 = 7.5
        // 2.5 = 0_10000001_01000000000000000000000 (0x40200000)
        // 3.0 = 0_10000001_10000000000000000000000 (0x40400000)
        // 7.5 = 0_10000010_11100000000000000000000 (0x40F00000)
        #10;
        A = 32'h40200000;
        B = 32'h40400000;
        #20; // Wait for pipeline
        
        // Test case 2: (-2.0) * 4.0 = -8.0
        // -2.0 = 1_10000000_00000000000000000000000 (0xC0000000)
        // 4.0 = 0_10000010_00000000000000000000000 (0x40800000)
        // -8.0 = 1_10000011_00000000000000000000000 (0xC1000000)
        #10;
        A = 32'hC0000000;
        B = 32'h40800000;
        #20;
        
        // Test case 3: 0.0 * 5.0 = 0.0
        // 0.0 = 0_00000000_00000000000000000000000 (0x00000000)
        // 5.0 = 0_10000010_01000000000000000000000 (0x40A00000)
        #10;
        A = 32'h00000000;
        B = 32'h40A00000;
        #20;
        
        // End simulation
        #50;
        $finish;
    end
endmodule