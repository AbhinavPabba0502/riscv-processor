module alu (
    input  [31:0] srcA,      // First operand (e.g., rs1)
    input  [31:0] srcB,      // Second operand (e.g., rs2 or immediate)
    input  [2:0]  alu_op,    // ALU operation: 000=ADD, 001=SUB, 010=SLT, 011=OR, 100=AND
    output reg [31:0] result, // Result of the operation
    output        zero       // Zero flag (1 if result == 0)
);

    // Compute the result based on alu_op
    always @(*) begin
        case (alu_op)
            3'b000: result = srcA + srcB;  // ADD
            3'b001: result = srcA - srcB;  // SUB
            3'b010: result = (srcA < srcB) ? 32'd1 : 32'd0; // SLT
            3'b011: result = srcA | srcB;  // OR
            3'b100: result = srcA & srcB;  // AND
            default: result = 32'b0;       // Default to 0 for undefined ops
        endcase
    end

    // Zero flag: 1 if result is 0, 0 otherwise
    assign zero = (result == 32'b0);
endmodule