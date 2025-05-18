module fp_add_sub(
    input clk,
    input reset,
    input [31:0] A,        // First IEEE 754 number
    input [31:0] B,        // Second IEEE 754 number
    input op,              // Operation: 0 = add, 1 = subtract
    output reg [31:0] result // Result of A + B or A - B
);
    // Extract components
    wire sign_A = A[31];
    wire sign_B = B[31];
    wire [7:0] exp_A = A[30:23];
    wire [7:0] exp_B = B[30:23];
    wire [22:0] mant_A = A[22:0];
    wire [22:0] mant_B = B[22:0];

    // Hidden bit and full mantissa
    wire [23:0] mant_A_full = {1'b1, mant_A};
    wire [23:0] mant_B_full = {1'b1, mant_B};

    // Special case detection
    wire is_zero_A = (exp_A == 8'h00) && (mant_A == 23'h0);
    wire is_zero_B = (exp_B == 8'h00) && (mant_B == 23'h0);
    wire is_nan_A = (exp_A == 8'hFF) && (mant_A != 23'h0);
    wire is_nan_B = (exp_B == 8'hFF) && (mant_B != 23'h0);
    wire is_inf_A = (exp_A == 8'hFF) && (mant_A == 23'h0);
    wire is_inf_B = (exp_B == 8'hFF) && (mant_B == 23'h0);

    // Internal signals
    reg [7:0] exp_result;
    reg [23:0] mant_result;
    reg sign_result;
    reg [24:0] sum_mant;
    reg [7:0] exp_diff;
    reg [23:0] mant_small, mant_large;
    reg [7:0] exp_large;
    reg sign_large;

    // Handle subtraction by negating B's sign if op = 1
    wire [31:0] B_modified = op ? {~B[31], B[30:0]} : B;
    wire sign_B_modified = B_modified[31];

    // Instantiate fpu_compare
    wire comp_equal, comp_less, comp_greater;
    fp_comp comparator (
        .A(A),
        .B(B_modified),
        .equal(comp_equal),
        .less(comp_less),
        .greater(comp_greater)
    );

    always @(posedge clk, posedge reset) begin
        // Default result
        if (reset) begin
        result = 32'h0;
        end
        
        // Handle special cases
        if (is_nan_A || is_nan_B) begin
            result = {1'b0, 8'hFF, 23'h1}; // NaN
        end
        else if (is_inf_A && is_inf_B && (sign_A != sign_B_modified)) begin
            result = {1'b0, 8'hFF, 23'h1}; // NaN (inf - inf)
        end
        else if (is_inf_A) begin
            result = {sign_A, 8'hFF, 23'h0}; // Infinity
        end
        else if (is_inf_B) begin
            result = {sign_B_modified, 8'hFF, 23'h0}; // Infinity
        end
        else if (is_zero_A && is_zero_B) begin
            result = {1'b0, 8'h00, 23'h0}; // Zero
        end
        else if (is_zero_A) begin
            result = B_modified;
        end
        else if (is_zero_B) begin
            result = A;
        end
        else begin
            // Determine larger number using fpu_compare outputs
            if (comp_greater || comp_equal) begin // A >= B
                exp_large = exp_A;
                mant_large = mant_A_full;
                mant_small = mant_B_full;
                sign_large = sign_A;
                exp_diff = exp_A - exp_B;
            end
            else begin // B > A
                exp_large = exp_B;
                mant_large = mant_B_full;
                mant_small = mant_A_full;
                sign_large = sign_B_modified;
                exp_diff = exp_B - exp_A;
            end

            // Align mantissas
            mant_small = (exp_diff > 24) ? 24'h0 : (mant_small >> exp_diff);

            // Perform addition or subtraction based on signs
            if (sign_A == sign_B_modified) begin
                sum_mant = mant_large + mant_small;
                sign_result = sign_A;
            end
            else begin
                sum_mant = mant_large - mant_small;
                sign_result = sign_large;
            end

            // Normalize result
            exp_result = exp_large;
            mant_result = sum_mant[23:0];

            if (sum_mant[24]) begin // overflow
                mant_result = sum_mant[24:1];
                exp_result = exp_result + 1;
            end
            else if (sum_mant[23] == 1'b0 && sum_mant != 25'h0) begin // Normalize left
                while (mant_result[23] == 1'b0 && exp_result > 0) begin
                    mant_result = mant_result << 1;
                    exp_result = exp_result - 1;
                end
            end

            // Check for zero result
            if (sum_mant == 25'h0) begin
                result = {1'b0, 8'h00, 23'h0};
            end
            else begin
                result = {sign_result, exp_result, mant_result[22:0]};
            end
        end
    end
endmodule