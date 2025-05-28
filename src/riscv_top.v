module riscv_top (
    input clk,
    input reset,
    output [31:0] pc,
    output [31:0] result
);

    // Pipeline registers
    reg [31:0] if_id_pc, id_ex_pc, ex_mem_pc, mem_wb_pc;
    reg [31:0] if_id_inst, id_ex_inst, ex_mem_inst, mem_wb_inst;
    reg [31:0] id_ex_rs1, id_ex_rs2, ex_mem_alu_out, mem_wb_alu_out;
    reg [31:0] ex_mem_mem_data, mem_wb_mem_data;
    reg [4:0] id_ex_rd, ex_mem_rd, mem_wb_rd;

    // Control signals
    wire [3:0] alu_op;
    wire mem_write, mem_read, reg_write;
    wire [1:0] alu_src;
    wire branch;

    // Instruction Fetch
    reg [31:0] pc_reg;
    wire [31:0] inst;
    instruction_memory imem (.addr(pc_reg), .inst(inst));

    always @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 0;
        else pc_reg <= pc_reg + 4;
    end
    assign pc = pc_reg;

    // IF/ID Pipeline
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc <= 0;
            if_id_inst <= 0;
        end else begin
            if_id_pc <= pc_reg;
            if_id_inst <= inst;
        end
    end

    // Decode
    wire [31:0] rs1_data, rs2_data;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    control_unit ctrl (
        .inst(if_id_inst),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .branch(branch),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm)
    );
    register_file regs (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(mem_wb_rd),
        .write_data(mem_wb_alu_out),
        .reg_write(mem_wb_reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ID/EX Pipeline
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_pc <= 0;
            id_ex_inst <= 0;
            id_ex_rs1 <= 0;
            id_ex_rs2 <= 0;
            id_ex_rd <= 0;
        end else begin
            id_ex_pc <= if_id_pc;
            id_ex_inst <= if_id_inst;
            id_ex_rs1 <= rs1_data;
            id_ex_rs2 <= rs2_data;
            id_ex_rd <= rd;
        end
    end

    // Execute
    wire [31:0] alu_in2, alu_out;
    assign alu_in2 = (alu_src == 2'b01) ? imm : id_ex_rs2;
    alu alu_inst (
        .a(id_ex_rs1),
        .b(alu_in2),
        .op(alu_op),
        .result(alu_out)
    );

    // EX/MEM Pipeline
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_pc <= 0;
            ex_mem_inst <= 0;
            ex_mem_alu_out <= 0;
            ex_mem_rd <= 0;
        end else begin
            ex_mem_pc <= id_ex_pc;
            ex_mem_inst <= id_ex_inst;
            ex_mem_alu_out <= alu_out;
            ex_mem_rd <= id_ex_rd;
        end
    end

    // Memory
    wire [31:0] mem_data;
    data_memory dmem (
        .clk(clk),
        .addr(ex_mem_alu_out),
        .write_data(ex_mem_rs2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_data)
    );

    // MEM/WB Pipeline
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_pc <= 0;
            mem_wb_inst <= 0;
            mem_wb_alu_out <= 0;
            mem_wb_mem_data <= 0;
            mem_wb_rd <= 0;
        end else begin
            mem_wb_pc <= ex_mem_pc;
            mem_wb_inst <= ex_mem_inst;
            mem_wb_alu_out <= ex_mem_alu_out;
            mem_wb_mem_data <= mem_data;
            mem_wb_rd <= ex_mem_rd;
        end
    end

    // Write-back
    assign result = mem_read ? mem_wb_mem_data : mem_wb_alu_out;

endmodule