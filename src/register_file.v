module register_file (
    input clk,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
    reg [31:0] regs [0:31];
    initial regs[0] = 0; // x0 is hardwired to 0
    always @(posedge clk) begin
        if (reg_write && rd != 0)
            regs[rd] <= write_data;
    end
    assign rs1_data = regs[rs1];
    assign rs2_data = regs[rs2];
endmodule