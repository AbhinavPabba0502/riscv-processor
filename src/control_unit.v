module control_unit (
    input  [6:0] opcode,       // Instruction opcode
    input  [2:0] funct3,       // Function code for R-type and some I-type instructions
    input  [6:0] funct7,       // Function code for R-type instructions
    output reg [2:0] alu_op,   // ALU operation: 000=ADD, 001=SUB, 010=SLT, 011=OR, 100=AND
    output reg       mem_write,// Data memory write enable
    output reg       reg_write,// Register file write enable
    output reg       alu_src,  // ALU srcB select (0=reg, 1=imm)
    output reg       mem_to_reg,// Write-back source (0=ALU, 1=mem)
    output reg       branch    // Branch signal
);

    always @(*) begin
        // Default values
        alu_op     = 3'b000;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, SLT, OR, AND)
                reg_write = 1'b1;
                alu_src   = 1'b0;
                mem_to_reg = 1'b0;
                case ({funct7, funct3})
                    10'b0000000_000: alu_op = 3'b000; // ADD
                    10'b0100000_000: alu_op = 3'b001; // SUB
                    10'b0000000_010: alu_op = 3'b010; // SLT
                    10'b0000000_110: alu_op = 3'b011; // OR
                    10'b0000000_111: alu_op = 3'b100; // AND
                    default: alu_op = 3'b000;         // Default to ADD
                endcase
            end
            7'b0010011: begin // I-type (ADDI)
                reg_write = 1'b1;
                alu_src   = 1'b1;
                mem_to_reg = 1'b0;
                alu_op    = 3'b000; // ADD
            end
            7'b0000011: begin // I-type (LW)
                reg_write = 1'b1;
                alu_src   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op    = 3'b000; // ADD for address calculation
            end
            7'b0100011: begin // S-type (SW)
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 3'b000; // ADD for address calculation
            end
            7'b1100011: begin // B-type (BEQ)
                branch    = 1'b1;
                alu_src   = 1'b0;
                alu_op    = 3'b001; // SUB for comparison
            end
            default: begin
                alu_op     = 3'b000;
                mem_write  = 1'b0;
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b0;
            end
        endcase
    end
endmodule