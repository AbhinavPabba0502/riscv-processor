module instruction_memory (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255]; // 256-word instruction memory

    initial begin
        // Example instructions (replace with your own)
        mem[0] = 32'h005302b3; // ADD x5, x6, x5
        mem[1] = 32'h405302b3; // SUB x5, x6, x5
        mem[2] = 32'h00530333; // SLT x6, x6, x5
        mem[3] = 32'h005363b3; // OR x7, x6, x5
        mem[4] = 32'h005373b3; // AND x7, x6, x5
        mem[5] = 32'h00530093; // ADDI x1, x6, 5
        mem[6] = 32'h00032083; // LW x1, 0(x6)
        mem[7] = 32'h00532023; // SW x5, 0(x6)
        mem[8] = 32'hfe528ee3; // BEQ x5, x5, -4
    end

    assign instr = mem[addr >> 2];
endmodule