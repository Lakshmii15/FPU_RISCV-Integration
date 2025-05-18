module fp_comp(
    input [31:0] A, // First IEEE 754 number
    input [31:0] B, // Second IEEE 754 number
    output reg equal, // 1 if A == B
    output reg less,  // 1 if A < B
    output reg greater // 1 if A > B
);
    // Extract sign, exponent, and mantissa
    wire sign_A = A[31];
    wire sign_B = B[31];
    wire [7:0] exp_A = A[30:23];
    wire [7:0] exp_B = B[30:23];
    wire [22:0] mant_A = A[22:0];
    wire [22:0] mant_B = B[22:0];

    // Check for special cases (NaN, infinity, zero)
    wire is_zero_A = (exp_A == 8'h00) && (mant_A == 23'h0);
    wire is_zero_B = (exp_B == 8'h00) && (mant_B == 23'h0);
    wire is_nan_A = (exp_A == 8'hFF) && (mant_A != 23'h0);
    wire is_nan_B = (exp_B == 8'hFF) && (mant_B != 23'h0);
    wire is_inf_A = (exp_A == 8'hFF) && (mant_A == 23'h0);
    wire is_inf_B = (exp_B == 8'hFF) && (mant_B == 23'h0);

    always @(A, B) begin
        // Default outputs
        equal = 1'b0;
        less = 1'b0;
        greater = 1'b0;

        // Handle NaN cases (no comparison possible)
        if (is_nan_A || is_nan_B) begin
            equal = 1'b0;
            less = 1'b0;
            greater = 1'b0;
        end
        // Handle zero cases
        else if (is_zero_A && is_zero_B) begin
            equal = 1'b1;
        end
        // Handle infinity cases
        else if (is_inf_A && is_inf_B) begin
            if (sign_A == sign_B)
                equal = 1'b1;
            else if (sign_A == 1'b1)
                less = 1'b1;
            else
                greater = 1'b1;
        end
        else if (is_inf_A) begin
            if (sign_A == 1'b1)
                less = 1'b1;
            else
                greater = 1'b1;
        end
        else if (is_inf_B) begin
            if (sign_B == 1'b1)
                greater = 1'b1;
            else
                less = 1'b1;
        end
        // Normal comparison
        else begin
            // Compare signs
            if (sign_A > sign_B) begin
                less = 1'b1;
            end
            else if (sign_A < sign_B) begin
                greater = 1'b1;
            end
            else begin
                // Same sign, compare exponent and mantissa
                if (exp_A == exp_B && mant_A == mant_B) begin
                    equal = 1'b1;
                end
                else if (sign_A == 1'b0) begin // Positive numbers
                    if (exp_A > exp_B || (exp_A == exp_B && mant_A > mant_B))
                        greater = 1'b1;
                    else
                        less = 1'b1;
                end
                else begin // Negative numbers
                    if (exp_A > exp_B || (exp_A == exp_B && mant_A > mant_B))
                        less = 1'b1;
                    else
                        greater = 1'b1;
                end
            end
        end
    end
endmodule