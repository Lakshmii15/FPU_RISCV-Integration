module fp_add_sub (input clk,input reset,
    input  [31:0] A,  // FP number A
    input  [31:0] B,  // FP number B
    input  op, // 0 for add, 1 for subtract
    output reg [31:0] Result
);

    // Internal signals
    reg signA, signB, resultSign;
    reg [7:0] expA, expB, expDiff, resultExp;
    reg [23:0] mantA, mantB, alignedMantA, alignedMantB;
    reg [24:0] mantSum; // 1 extra bit for overflow
    reg [22:0] resultMant;

    wire comp_res;

    // Instantiate the comparator
    fp_Comp comp_inst (
        .clk(clk),
        .reset(reste),
        .A(A),
        .B(B),
        .res(comp_res)
    );

    always@(posedge clk, posedge reset) begin
        // Decompose inputs
        signA <= A[31];
        expA  <= A[30:23];
        mantA <= {1'b1, A[22:0]};  // Add implicit 1

        signB <= B[31] ^ op;       // Flip sign if subtract
        expB  <= B[30:23];
        mantB <= {1'b1, B[22:0]};  // Add implicit 1

        // Align exponents
        if (expA > expB) begin
            expDiff <= expA - expB;
            alignedMantA <= mantA;
            alignedMantB <= mantB >> expDiff;
            resultExp <= expA;
        end 
        else begin
            expDiff <= expB - expA;
            alignedMantA <= mantA >> expDiff;
            alignedMantB <= mantB;
            resultExp <= expB;
        end

        // Determine operation based on signs
        if (signA == signB) begin
            // Perform addition
            mantSum = alignedMantA + alignedMantB;
            resultSign <=signA;
        end 
        else begin
            // Perform subtraction (use comparator result)
            if (comp_res) begin
                mantSum <=alignedMantA - alignedMantB;
                resultSign <=signA;
            end else begin
                mantSum <=alignedMantB - alignedMantA;
                resultSign <=signB;
            end
        end

        // Normalize result
        if (mantSum[24]) begin
            mantSum <=mantSum >> 1;
            resultExp <=resultExp + 1;
        end 
        else begin
            // Shift left until MSB = 1 (optional simple normalization)
            while (mantSum[23] == 0 && resultExp > 0) begin
                mantSum <= mantSum << 1;
                resultExp <= resultExp - 1;
            end
        end

        // Assemble result
        resultMant <= mantSum[22:0];
        Result <= {resultSign, resultExp, resultMant};
    end

endmodule