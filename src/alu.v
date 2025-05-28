module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] op,
    output reg [31:0] result
);
    always @(*) begin
        case (op)
            4'b0000: result = a + b; // ADD
            4'b0001: result = a - b; // SUB
            default: result = 0;
        endcase
    end
endmodule