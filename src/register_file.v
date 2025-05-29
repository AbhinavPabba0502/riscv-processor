module register_file (
    input         clk,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] write_data,
    input         reg_write,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers [0:31];

    initial begin
        registers[0] = 32'b0; // x0 is always 0
        registers[5] = 32'd5; // x5 = 5
        registers[6] = 32'd10; // x6 = 10
    end

    always @(posedge clk) begin
        if (reg_write && rd != 0)
            registers[rd] <= write_data;
    end

    assign read_data1 = registers[rs1];
    assign read_data2 = registers[rs2];
endmodule