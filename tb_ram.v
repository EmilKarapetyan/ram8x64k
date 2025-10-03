`timescale 1ns/1ps
//`define DEBUG // Uncomment to enable debug mode
module tb_ram8x64k;
    parameter MATRIX_SIZE = 16;

    reg clk;
    reg we;
    reg [15:0] addr;
    reg [7:0] din;
    wire [7:0] dout;

    ram8x64k ram (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer row, col;
    integer row_error;
    reg [7:0] original_value_65535;
    reg [7:0] original_value_32768;
    reg [7:0] goldenRam [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];


    initial begin
        we = 0;
        addr = 0;
        din = 0;
        @(posedge clk);

        we = 1;
        for (row = 0; row < MATRIX_SIZE; row = row + 1) begin
            for (col = 0; col < MATRIX_SIZE; col = col + 1) begin
                addr = row*MATRIX_SIZE + col;
                din = (row & 1'b1) ? 8'd1 : 8'd0;
                #1;
                @(posedge clk);
            end
        end
        we = 0;

        $write("Testing Boundary Addresses: ");
        we = 0;
        addr = 65535;
        #1;
        @(posedge clk);
        original_value_65535 = dout;
        we = 1;
        addr = 65535;
        din = 8'd255;
        #1;
        @(posedge clk);
        we = 0;
        #1;
        @(posedge clk);
        if (dout != 8'd255) begin
            $write("Failed\nError at addr 65535: expected 255, got %0d", dout);
        end else begin
            $write("Passed");
            we = 1;
            addr = 65535;
            din = original_value_65535;
            #1;
            @(posedge clk);
            we = 0;
        end

        $write("\nTesting Random Addresses: ");
        we = 0;
        addr = 32768;
        #1;
        @(posedge clk);
        original_value_32768 = dout;
        we = 1;
        addr = 32768;
        din = 8'd128;
        #1;
        @(posedge clk);
        we = 0;
        #1;
        @(posedge clk);
        if (dout != 8'd128) begin
            $write("Failed\nError at addr 32768: expected 128, got %0d", dout);
        end else begin
            $write("Passed");
            we = 1;
            addr = 32768;
            din = original_value_32768;
            #1;
            @(posedge clk);
            we = 0;
        end

        for (row = 0; row < MATRIX_SIZE; row = row + 1) begin
            for (col = 0; col < MATRIX_SIZE; col = col + 1) begin
                goldenRam[row][col] = (row & 1'b1) ? 8'd1 : 8'd0;
            end
        end

        $write("\nComparison Phase: ");
        we = 0;
        @(posedge clk);
        for (row = 0; row < MATRIX_SIZE; row = row + 1) begin
            row_error = 0;
            for (col = 0; col < MATRIX_SIZE; col = col + 1) begin
                addr = row*MATRIX_SIZE + col;
                #1;
                @(posedge clk);
                #1;
                if (goldenRam[row][col] != dout) begin
                    row_error = 1;
                    $write("Failed\nError at addr %0d (row %0d, col %0d): expected %0d, got %0d", 
                            addr, row, col, goldenRam[row][col], dout);
                end
            end
        end
        if (row_error == 0) begin 
            $write("Passed\n");
        end

        `ifdef DEBUG
            $write("\nRAM Contents\n");
            we = 0;
            @(posedge clk);
            for (row = 0; row < MATRIX_SIZE; row = row + 1) begin
                for (col = 0; col < MATRIX_SIZE; col = col + 1) begin
                    addr = row*MATRIX_SIZE + col;
                    #1;
                    @(posedge clk);
                    $write("%3d ", dout);
                end
                $write("\n");
            end
            
            $write("\nPrinting goldenRam\n");
            for (row = 0; row < MATRIX_SIZE; row = row + 1) begin
                for (col = 0; col < MATRIX_SIZE; col = col + 1) begin
                    $write("%3d ", goldenRam[row][col]);
                end
                $write("\n");
            end
        `endif
        $finish;
    end
endmodule
