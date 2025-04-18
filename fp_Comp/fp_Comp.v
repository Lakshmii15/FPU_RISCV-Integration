module fp_Comp (input clk,input reset,
    input [31:0] A,  // FP number A
    input [31:0] B,  // FP number B
    output reg res);

// Split into sign, exponent, and mantissa
reg [7:0] expA, expB;
reg [22:0] mantA, mantB;

always @(posedge clk, posedge reset) begin
    // Decompose inputs
    expA   = A[30:23];
    mantA  = A[22:0];

    expB   = B[30:23];
    mantB  = B[22:0];

    // If A>B - res = 1 ; else res = 0
    if (reset)
        res = 1'b0;
    // If signs differ
    if (A[31] != B[31]) begin
        res = ~ A[31]; // A is positive (0) -> A >= B -> result = 1
    end
    // If both signs are the same
    else if (expA != expB) begin
           res = ( expA > expB && A[31] == 1'b0 ) ? 1'b1 : 1'b0;
        end 
    else begin
            // Exponents equal, compare mantissa
            if (mantA != mantB) begin
                res = (mantA > mantB && A[31] == 1'b0) ? 1'b1 : 1'b0;
            end 
        end
    end
endmodule