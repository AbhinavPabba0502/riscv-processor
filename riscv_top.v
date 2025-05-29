module riscv_top (
    input         clk,
    input         reset,
    output [31:0] pc,
    output [31:0] result
);

    // Pipeline registers
    reg [31:0] if_id_pc, id_ex_pc, ex_mem_result, mem_wb_result;
    reg [31:0] if_id_inst;
    reg [31:0] id_ex_operand1, id_ex_operand2, id_ex_imm;
    reg [4:0]  id_ex_rd, ex_mem_rd, mem_wb_rd;
    reg [2:0]  id_ex_alu_op;
    reg        id_ex_alu_src, id_ex_mem_write, id_ex_reg_write, id_ex_mem_to_reg, id_ex_branch;
    reg        ex_mem_mem_write, ex_mem_reg_write, ex_mem_mem_to_reg, ex_mem_branch;
    reg        mem_wb_reg_write, mem_wb_mem_to_reg;
    reg [31:0] ex_mem_alu_result, ex_mem_store_data;
    reg        ex_mem_zero;

    // Fetch Stage
    reg [31:0] pc_reg;
    wire [31:0] next_pc, instruction;
    assign pc = pc_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 32'b0;
        else
            pc_reg <= next_pc;
    end

    instruction_memory imem (
        .addr(pc_reg),
        .instr(instruction)
    );

    assign next_pc = ex_mem_branch && ex_mem_zero ? ex_mem_result : (pc_reg + 4);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc <= 32'b0;
            if_id_inst <= 32'b0;
        end else begin
            if_id_pc <= pc_reg;
            if_id_inst <= instruction;
        end
    end

    // Decode Stage
    wire [6:0] opcode = if_id_inst[6:0];
    wire [2:0] funct3 = if_id_inst[14:12];
    wire [6:0] funct7 = if_id_inst[31:25];
    wire [4:0] rs1 = if_id_inst[19:15];
    wire [4:0] rs2 = if_id_inst[24:20];
    wire [4:0] rd = if_id_inst[11:7];
    wire [31:0] imm = (opcode == 7'b0010011 || opcode == 7'b0000011) ? {{20{if_id_inst[31]}}, if_id_inst[31:20]} :  // I-type
                      (opcode == 7'b0100011) ? {{20{if_id_inst[31]}}, if_id_inst[31:25], if_id_inst[11:7]} :  // S-type
                      (opcode == 7'b1100011) ? {{19{if_id_inst[31]}}, if_id_inst[31], if_id_inst[7], if_id_inst[30:25], if_id_inst[11:8], 1'b0} : 32'b0; // B-type

    wire [2:0] alu_op;
    wire mem_write, reg_write, alu_src, mem_to_reg, branch;

    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .branch(branch)
    );

    wire [31:0] read_data1, read_data2;
    register_file regfile (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(mem_wb_rd),
        .write_data(result),
        .reg_write(mem_wb_reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_operand1 <= 32'b0;
            id_ex_operand2 <= 32'b0;
            id_ex_imm <= 32'b0;
            id_ex_rd <= 5'b0;
            id_ex_alu_op <= 3'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_branch <= 1'b0;
            id_ex_pc <= 32'b0;
        end else begin
            id_ex_operand1 <= read_data1;
            id_ex_operand2 <= read_data2;
            id_ex_imm <= imm;
            id_ex_rd <= rd;
            id_ex_alu_op <= alu_op;
            id_ex_alu_src <= alu_src;
            id_ex_mem_write <= mem_write;
            id_ex_reg_write <= reg_write;
            id_ex_mem_to_reg <= mem_to_reg;
            id_ex_branch <= branch;
            id_ex_pc <= if_id_pc;
        end
    end

    // Execute Stage
    wire [31:0] alu_srcB = id_ex_alu_src ? id_ex_imm : id_ex_operand2;
    wire [31:0] alu_result;
    wire zero;

    alu alu_inst (
        .srcA(id_ex_operand1),
        .srcB(alu_srcB),
        .alu_op(id_ex_alu_op),
        .result(alu_result),
        .zero(zero)
    );

    wire [31:0] branch_target = id_ex_pc + (id_ex_imm << 1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_alu_result <= 32'b0;
            ex_mem_store_data <= 32'b0;
            ex_mem_rd <= 5'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
            ex_mem_branch <= 1'b0;
            ex_mem_zero <= 1'b0;
            ex_mem_result <= 32'b0;
        end else begin
            ex_mem_alu_result <= alu_result;
            ex_mem_store_data <= id_ex_operand2;
            ex_mem_rd <= id_ex_rd;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_branch <= id_ex_branch;
            ex_mem_zero <= zero;
            ex_mem_result <= branch_target;
        end
    end

    // Memory Stage
    wire [31:0] mem_data;
    data_memory dmem (
        .clk(clk),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_store_data),
        .write_enable(ex_mem_mem_write),
        .read_data(mem_data)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_result <= 32'b0;
            mem_wb_rd <= 5'b0;
            mem_wb_reg_write <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;
        end else begin
            mem_wb_result <= ex_mem_mem_to_reg ? mem_data : ex_mem_alu_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        end
    end

    // Write-back Stage
    assign result = mem_wb_result;

endmodule