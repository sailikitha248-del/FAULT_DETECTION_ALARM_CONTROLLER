module top_module (
    input clk,
    input rst,
    input fault_in,
    output [3:0] fault_count,
    output alarm
);

    wire fault_pulse;

    fault_detector FD (
        .clk(clk),
        .rst(rst),
        .fault_in(fault_in),
        .fault_pulse(fault_pulse)
    );

    fault_counter FC (
        .clk(clk),
        .rst(rst),
        .fault_pulse(fault_pulse),
        .fault_count(fault_count)
    );

    alarm_controller AC (
        .clk(clk),
        .rst(rst),
        .fault_count(fault_count),
        .alarm(alarm)
    );

endmodule
