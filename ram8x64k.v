`timescale 1ns/1ps

module ram8x64k (
    input clk,
    input we,
    input [15:0] addr,
    input [7:0] din,
    output reg [7:0] dout
);
    reg [7:0] mem [0:65535];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end else begin
            dout <= mem[addr];
        end
    end

endmodule