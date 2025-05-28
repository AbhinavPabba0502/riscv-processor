module riscv_tb;
    reg clk, reset;
    wire [31:0] pc, result;

    riscv_top dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .result(result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset = 0;
        #100 $display("PC: %h, Result: %h", pc, result);
        #100 $finish;
    end

    initial begin
        $dumpfile("riscv.vcd");
        $dumpvars(0, riscv_tb);
    end
endmodule