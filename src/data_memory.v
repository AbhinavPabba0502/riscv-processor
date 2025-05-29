module data_memory (
    input         clk,
    input  [31:0] addr,
    input  [31:0] write_data,
    input         write_enable,
    output [31:0] read_data
);
    reg [31:0] mem [0:255]; // 256-word data memory

    always @(posedge clk) begin
        if (write_enable)
            mem[addr >> 2] <= write_data;
    end

    assign read_data = mem[addr >> 2];
endmodule