module control_unit (
    input [31:0] inst,
    output reg [3:0] alu_op,
    output reg mem_write,
    output reg mem_read,
    output reg reg_write,
    output reg [1:0] alu_src,
    output reg branch,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm
);
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type (ADD)
                alu_op = (funct3 == 3'b000) ? 4'b0000 : 4'b0001;
                mem_write = 0;
                mem_read = 0;
                reg_write = 1;
                alu_src = 2'b00;
                branch = 0;
            end
            7'b0010011: begin // I-type (ADDI)
                alu_op = 4'b0000;
                mem_write = 0;
                mem_read = 0;
                reg_write = 1;
                alu_src = 2'b01;
                branch = 0;
            end
            default: begin
                alu_op = 4'b0000;
                mem_write = 0;
                mem_read = 0;
                reg_write = 0;
                alu_src = 2'b00;
                branch = 0;
            end
        endcase
    end
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];
    assign imm = {{20{inst[31]}}, inst[31:20]};
endmodule