module fp_Comp (
    input clk,
    input reset,
    input [31:0] A,  // FP number A
    input [31:0] B,  // FP number B
    output reg res
);

    // Wires for decomposition
    wire [7:0] expA = A[30:23];
    wire [7:0] expB = B[30:23];
    wire [22:0] mantA = A[22:0];
    wire [22:0] mantB = B[22:0];

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            res <= 1'b0;
        end else begin
            // If signs differ
            if (A[31] != B[31]) begin
                res <= ~A[31]; // A is positive (0) -> A >= B -> result = 1
            end
            // If both signs are the same
            else if (expA != expB) begin
                res <= (expA > expB && A[31] == 1'b0) ? 1'b1 : 1'b0;
            end 
            else begin
                // Exponents equal, compare mantissa
                if (mantA != mantB) begin
                    res <= (mantA > mantB && A[31] == 1'b0) ? 1'b1 : 1'b0;
                end else begin
                    res <= 1'b0; // A == B
                end
            end
        end
    end
endmodule