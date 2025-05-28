module instruction_memory (
    input [31:0] addr,
    output [31:0] inst
);
    reg [31:0] mem [0:255];
    initial begin
        // Sample instructions (ADD, LW, BEQ)
        mem[0] = 32'h00500293; // addi x5, x0, 5
        mem[4] = 32'h00A00313; // addi x6, x0, 10
        mem[8] = 32'h006283B3; // add x7, x5, x6
    end
    assign inst = mem[addr[9:2]];
endmodule