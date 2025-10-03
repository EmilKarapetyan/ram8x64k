`timescale 1ns/1ps
//`define DEBUG // Uncomment to enable debug mode
module tb_register;

    reg clk;
    reg we;
    reg  [3:0] waddr;    
    reg [7:0] wdata;
    reg  [3:0] raddr1;
    reg  [3:0] raddr2;
    wire [7:0] rdata1;
    wire [7:0] rdata2;

    register8x16 register (
        .clk(clk),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    initial clk = 0;
    always #5 clk = ~clk; 

    integer idx;
    reg error_found;

    initial begin
        $dumpfile("ramWave.vcd");
        $dumpvars(0, tb_ram8x64k, ram.mem[0], ram.mem[1], ram.mem[32768], ram.mem[65535]);
    end

    initial begin
        we = 0;
        waddr = 4'd0;
        wdata = 8'd0;
        raddr1 = 4'd0;
        raddr2 = 4'd0;
        error_found = 1'b0;

        $write("Write enable test: ");
        we = 0;
        waddr = 4'd6;
        wdata = 8'd55;
        @(posedge clk);
        raddr1 = 4'd6;
        @(posedge clk);

        if (rdata1 == 8'd55) begin
            $write("Failed\nError at addr %0d: value got changed when write enable is disabled\n", waddr);
        end else $write("Passed\n");

        $write("Write-Read test: ");
        for (idx = 0; idx < 16; idx = idx + 1) begin
            @(posedge clk);
            we = 1; waddr = idx; wdata = idx;
            @(posedge clk);
        end
        @(posedge clk);

        we = 0;
        @(posedge clk);
        for (idx = 0; idx < 8; idx = idx + 1) begin
            raddr1 = idx; raddr2 = 8+idx;
            @(posedge clk);
            if (rdata1 != idx) begin
                $write("Failed\nError at addr %0d: expected %0d, got %0d\n", idx, idx, rdata1);
                error_found = 1'b1;
            end
            if (rdata2 != idx+8) begin
                $write("Failed\nError at addr %0d: expected %0d, got %0d\n", idx+8, idx+8, rdata2);
                error_found = 1'b1;
            end
        end
        if (!error_found) $write("Passed\n");

        $write("Dual read test: ");
        we = 0;
        raddr1 = 4'd3;
        raddr2 = 4'd3;
        @(posedge clk);
        if (rdata1 != rdata2) begin 
            $write("Failed\nError at addr %0d: expected same value, got %0d and %0d\n", raddr1, rdata1, ,rdata2);
        end else begin
            $write("Passed\n");
        end
        $finish;
    end
endmodule