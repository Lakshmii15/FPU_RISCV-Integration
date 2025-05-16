module fpu_div (
    input wire [31:0] A,       // First operand
    input wire [31:0] B,       // Second operand
    input wire clk,            // Clock
    input wire reset,          // Reset
    output reg [31:0] result,  // Result
    output reg valid           // Output valid flag
);

    // IEEE 754 fields
    wire sign_A = A[31];
    wire sign_B = B[31];
    wire [7:0] exp_A = A[30:23];
    wire [7:0] exp_B = B[30:23];
    wire [22:0] mant_A = A[22:0];
    wire [22:0] mant_B = B[22:0];

    // Hidden bit (1 for normalized numbers)
    wire [23:0] mant_A_full = {1'b1, mant_A};
    wire [23:0] mant_B_full = {1'b1, mant_B};

    // Special case detection
    wire is_zero_A = (exp_A == 8'h00) && (mant_A == 23'h0);
    wire is_zero_B = (exp_B == 8'h00) && (mant_B == 23'h0);
    wire is_inf_A = (exp_A == 8'hFF) && (mant_A == 23'h0);
    wire is_inf_B = (exp_B == 8'hFF) && (mant_B == 23'h0);
    wire is_nan_A = (exp_A == 8'hFF) && (mant_A != 23'h0);
    wire is_nan_B = (exp_B == 8'hFF) && (mant_B != 23'h0);

    // Result components
    reg sign_res;
    reg [7:0] exp_res;
    reg [22:0] mant_res;
    reg [47:0] mant_div;
    reg [8:0] exp_diff;
    reg [4:0] state;
    reg [23:0] dividend;
    reg [23:0] divisor;
    reg [47:0] quotient;
    reg [5:0] div_count;

    // States
    localparam IDLE = 5'd0,
               CHECK_SPECIAL = 5'd1,
               COMPUTE_SIGN_EXP = 5'd2,
               DIVIDE_MANT = 5'd3,
               NORMALIZE = 5'd4,
               FINALIZE = 5'd5;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            result <= 32'h0;
            valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 1'b0;
                    if (!reset) begin
                        state <= CHECK_SPECIAL;
                    end
                end

                CHECK_SPECIAL: begin
                    // NaN cases
                    if (is_nan_A || is_nan_B) begin
                        result <= {1'b0, 8'hFF, 23'h400000}; // NaN
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    // Infinity cases
                    else if (is_inf_A && is_inf_B) begin
                        result <= {1'b0, 8'hFF, 23'h400000}; // NaN
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    else if (is_inf_A) begin
                        result <= {sign_A ^ sign_B, 8'hFF, 23'h0}; // Inf
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    else if (is_inf_B) begin
                        result <= {sign_A ^ sign_B, 8'h00, 23'h0}; // Zero
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    // Zero cases
                    else if (is_zero_A && is_zero_B) begin
                        result <= {1'b0, 8'hFF, 23'h400000}; // NaN
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    else if (is_zero_A) begin
                        result <= {sign_A ^ sign_B, 8'h00, 23'h0}; // Zero
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    else if (is_zero_B) begin
                        result <= {sign_A ^ sign_B, 8'hFF, 23'h0}; // Inf
                        valid <= 1'b1;
                        state <= IDLE;
                    end
                    else begin
                        state <= COMPUTE_SIGN_EXP;
                    end
                end

                COMPUTE_SIGN_EXP: begin
                    sign_res <= sign_A ^ sign_B;
                    exp_diff <= {1'b0, exp_A} - {1'b0, exp_A} + 9'd127;
                    dividend <= mant_A_full;
                    divisor <= mant_B_full;
                    quotient <= 48'h0;
                    div_count <= 6'd0;
                    state <= DIVIDE_MANT;
                end

                DIVIDE_MANT: begin
                    if (div_count < 24) begin
                        quotient <= quotient << 1;
                        if (dividend >= divisor) begin
                            quotient[0] <= 1'b1;
                            dividend <= dividend - divisor;
                        end
                        dividend <= dividend << 1;
                        div_count <= div_count + 1;
                    end else begin
                        mant_div <= quotient;
                        state <= NORMALIZE;
                    end
                end

                NORMALIZE: begin
                    if (mant_div[47] == 1'b1) begin
                        mant_res <= mant_div[46:24];
                        exp_res <= exp_diff[7:0];
                    end else if (mant_div[46] == 1'b1) begin
                        mant_res <= mant_div[45:23];
                        exp_res <= exp_diff[7:0] - 8'd1;
                    end else begin
                        mant_res <= 23'h0;
                        exp_res <= 8'h0;
                    end

                    // Handle overflow/underflow
                    if (exp_diff[8] || exp_diff > 9'd254) begin
                        // Overflow to infinity
                        result <= {sign_res, 8'hFF, 23'h0};
                        valid <= 1'b1;
                        state <= IDLE;
                    end else if (exp_diff < 9'd1) begin
                        // Underflow to zero
                        result <= {sign_res, 8'h00, 23'h0};
                        valid <= 1'b1;
                        state <= IDLE;
                    end else begin
                        state <= FINALIZE;
                    end
                end

                FINALIZE: begin
                    result <= {sign_res, exp_res, mant_res};
                    valid <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule