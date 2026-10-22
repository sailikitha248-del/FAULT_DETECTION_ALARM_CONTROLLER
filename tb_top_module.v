`timescale 1ns/1ps

module tb_top_module;

    reg clk;
    reg rst;
    reg fault_in;

    wire [3:0] fault_count;
    wire alarm;

    top_module uut (
        .clk(clk),
        .rst(rst),
        .fault_in(fault_in),
        .fault_count(fault_count),
        .alarm(alarm)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fault_waveform.vcd");
        $dumpvars(0, tb_top_module);

        clk = 0;
        rst = 1;
        fault_in = 0;

        #10;
        rst = 0;

        #10 fault_in = 1;
        #10 fault_in = 0;

        #10 fault_in = 1;
        #10 fault_in = 0;

        #10 fault_in = 1;
        #10 fault_in = 0;

        #30;
        $finish;
    end

    initial begin
        $monitor("Time=%0t rst=%b fault_in=%b count=%d alarm=%b",
                 $time, rst, fault_in, fault_count, alarm);
    end

endmodule
