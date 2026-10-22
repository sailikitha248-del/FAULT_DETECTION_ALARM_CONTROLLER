module fault_counter (
    input clk,
    input rst,
    input fault_pulse,
    output reg [3:0] fault_count
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            fault_count <= 0;
        else if (fault_pulse)
            fault_count <= fault_count + 1'b1;
    end

endmodule
