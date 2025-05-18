module fp_div_tb;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] Result;
    wire valid;

    // Instantiate the Unit Under Test (UUT)
    fp_div uut (
        .A(A),
        .B(B),
        .clk(clk),
        .reset(reset),
        .Result(Result),
        .valid(valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Test procedure
    initial begin
        // Initialize inputs
        A = 32'h0;
        B = 32'h0;
        reset = 1;
        #20;
        reset = 0;

        // Test case 1: Normal division (2.5 / 0.5 = 5.0)
        A = 32'h40200000; // 2.5
        B = 32'h3F000000; // 0.5
        wait_for_valid();

        // Test case 2: Division by zero (1.0 / 0.0 = Inf)
        A = 32'h3F800000; // 1.0
        B = 32'h00000000; // 0.0
        wait_for_valid();

        // Test case 3: Zero divided by non-zero (0.0 / 1.0 = 0.0)
        A = 32'h00000000; // 0.0
        B = 32'h3F800000; // 1.0
        wait_for_valid();

        // Test case 4: Infinity divided by finite number (Inf / 1.0 = Inf)
        A = 32'h7F800000; // Inf
        B = 32'h3F800000; // 1.0
        wait_for_valid();

        // Test case 5: Finite number divided by infinity (1.0 / Inf = 0.0)
        A = 32'h3F800000; // 1.0
        B = 32'h7F800000; // Inf
        wait_for_valid();

        // Test case 6: NaN involved (NaN / 1.0 = NaN)
        A = 32'h7FC00000; // NaN
        B = 32'h3F800000; // 1.0
        wait_for_valid();

        // Test case 7: Zero divided by zero (0.0 / 0.0 = NaN)
        A = 32'h00000000; // 0.0
        B = 32'h00000000; // 0.0
        wait_for_valid();

        // Test case 8: Infinity divided by infinity (Inf / Inf = NaN)
        A = 32'h7F800000; // Inf
        B = 32'h7F800000; // Inf
        wait_for_valid();

        // Test case 9: Negative numbers (-2.0 / 0.5 = -4.0)
        A = 32'hC0000000; // -2.0
        B = 32'h3F000000; // 0.5
        wait_for_valid();

        // Finish simulation
        #100;
        $finish;
    end

    // Task to wait for valid output
    task wait_for_valid;
        begin
            @(posedge clk);
            while (!valid) begin
                @(posedge clk);
            end
         end
    endtask
endmodule