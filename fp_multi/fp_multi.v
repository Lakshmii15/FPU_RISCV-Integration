module fp_multi (
    input wire clk,              // Clock input
    input wire reset,            // Synchronous reset
    input wire [31:0] A,         // First input (IEEE 754 single-precision)
    input wire [31:0] B,         // Second input (IEEE 754 single-precision)
    output reg [31:0] Result     // Result (IEEE 754 single-precision)
);

    // Internal registers for pipeline stage
    reg [31:0] A_reg, B_reg;
    reg [31:0] Result_reg;

    // Extract fields from inputs
    wire sign_A = A_reg[31];
    wire sign_B = B_reg[31];
    wire [7:0] exp_A = A_reg[30:23];
    wire [7:0] exp_B = B_reg[30:23];
    wire [23:0] mant_A = {1'b1, A_reg[22:0]}; // Implicit leading 1
    wire [23:0] mant_B = {1'b1, B_reg[22:0]}; // Implicit leading 1

    // Intermediate signals
    reg sign_result;
    reg [8:0] exp_sum; // Extra bit for overflow
    reg [47:0] mant_product;
    reg [7:0] exp_result;
    reg [22:0] mant_result;

    // Detect zero inputs
    wire A_zero = (exp_A == 8'h00 && A_reg[22:0] == 23'h0);
    wire B_zero = (exp_B == 8'h00 && B_reg[22:0] == 23'h0);

    always @(posedge clk) begin
        if (reset) begin
            A_reg <= 32'b0;
            B_reg <= 32'b0;
            Result <= 32'b0;
            Result_reg <= 32'b0;
        end else begin
            // Pipeline stage 1: Register inputs
            A_reg <= A;
            B_reg <= B;

            // Compute sign
            sign_result <= sign_A ^ sign_B;

            // Compute exponent (subtract bias 127)
            exp_sum <= exp_A + exp_B - 8'd127;

            // Multiply mantissas
            mant_product <= mant_A * mant_B;

            // Pipeline stage 2: Normalize and adjust
            if (A_zero || B_zero) begin
                Result_reg <= 32'b0; // Result is zero if either input is zero
            end else begin
                // Normalize mantissa
                if (mant_product[47]) begin
                    // Shift right by 1, increment exponent
                    mant_result <= mant_product[46:24];
                    exp_result <= exp_sum + 1;
                end else begin
                    mant_result <= mant_product[45:23];
                    exp_result <= exp_sum;
                end

                // Handle overflow/underflow
                if (exp_result >= 8'hFF) begin
                    // Overflow: Set to infinity
                    Result_reg <= {sign_result, 8'hFF, 23'b0};
                end else if (exp_sum[8] || exp_result == 8'h00) begin
                    // Underflow: Set to zero
                    Result_reg <= {sign_result, 8'h00, 23'b0};
                end else begin
                    // Normal case
                    Result_reg <= {sign_result, exp_result, mant_result};
                end
            end

            // Output result
            Result <= Result_reg;
        end
    end
endmodule