`timescale 1ns/1ps

module register8x16 (
    input clk,
    input we,
    input  [3:0] waddr,
    input  [7:0] wdata,
    input  [3:0] raddr1,
    input  [3:0] raddr2,
    output reg [7:0] rdata1,
    output reg [7:0] rdata2
);
    reg [7:0] regs [0:15];
    always @(*) begin
       rdata1 = regs[raddr1];
       rdata2 = regs[raddr2];
    end

    always @(posedge clk) begin
        if (we) begin
            regs[waddr] <= wdata;
        end
    end
endmodule