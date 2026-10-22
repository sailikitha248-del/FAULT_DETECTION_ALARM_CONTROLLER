module fault_detector (
    input clk,
    input rst,
    input fault_in,
    output reg fault_pulse
);

    reg previous_fault;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            previous_fault <= 0;
            fault_pulse <= 0;
        end else begin
            fault_pulse <= fault_in & ~previous_fault;
            previous_fault <= fault_in;
        end
    end

endmodule
