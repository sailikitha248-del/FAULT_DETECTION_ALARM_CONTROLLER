module alarm_controller #(
    parameter THRESHOLD = 3
) (
    input clk,
    input rst,
    input [3:0] fault_count,
    output reg alarm
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            alarm <= 0;
        else
            alarm <= (fault_count >= THRESHOLD);
    end

endmodule
