# RAM8x64K and Testbench

## RAM Module
The `ram8x64k` module is a synchronous RAM with an 8-bit data width and 64K (2^16 = 65536) address space.

### Interface
- `clk`: Input clock (positive edge-triggered).
- `we`: Write enable (1 = write, 0 = read).
- `addr`: 16-bit address (0 to 65535).
- `din`: 8-bit input data for writes.
- `dout`: 8-bit output data for reads (registered).

### Behavior
- On `posedge clk`:
  - If `we = 1`, writes `din` to `mem[addr]`.
  - If `we = 0`, outputs `mem[addr]` to `dout`.
- Memory (`mem`) is uninitialized (`x`) at startup.
- Uses non-blocking assignments for synchronous operation.

### Implementation
Testbench
The testbench (tb_ram8x64k.v) verifies the RAM module with:

Clock: 100MHz (10ns period).
Write Phase: Writes 8'd0 (even rows) or 8'd1 (odd rows) to addresses 0–255 (16x16 matrix).
Additional Address Tests: Tests addresses 0, 1, 32768, and 65535 with values 9, 27, 196, and 255.
Back-to-Back Access: Tests rapid writes and reads to the same addresses.
Write-Read Interference: Writes 8'hAA to addr = 1000 and checks addr = 1001.
Comparison Phase: Compares RAM contents (0–255) with a golden model (goldenRam).
Waveform Dumping: Generates wave.vcd for debugging.

Parameters

MATRIX_SIZE = 16: Defines the 16x16 matrix for write and comparison phases.

Requirements

Simulator: Icarus Verilog, ModelSim, or Vivado Simulator.
Files: ram8x64k.v, tb_ram8x64k.v.

How to Run

Compile:

Icarus Verilog:iverilog -o tb_ram tb_ram8x64k.v ram8x64k.v


ModelSim:vlog tb_ram8x64k.v ram8x64k.v




Run:

Icarus Verilog:vvp tb_ram


ModelSim:vsim -c tb_ram8x64k
run -all
quit -sim




Debug Mode:

Uncomment `define DEBUG in tb_ram8x64k.v to print RAM and goldenRam contents.
Recompile and run.


View Waveform:

The testbench includes:initial begin
    $dumpfile("ramWave.vcd");
    $dumpvars(0, tb_ram8x64k, ram);
end


Open in GTKWave:gtkwave ramWave.vcd





Expected Output
For a correct RAM module:
Starting Write Phase 1
Testing Additional Addresses: 4/4 tests passed
Testing Back-to-Back Access: 4/4 tests passed
Testing Write-Read Interference: Passed
Comparison Phase: Passed

With debug mode, it prints RAM and goldenRam contents. Errors show as:
Failed
Error at addr X: expected Y, got Z

Debugging

Uninitialized Memory: mem starts as x. The write phase initializes 0–255, but 32768 and 65535 may show x if not written.
Timing: dout reflects mem[addr] from the previous clock cycle. The testbench uses delays (#1; @(posedge clk);) to handle this.
Waveform:
Check clk, we, addr, din, dout, ram.mem[0], ram.mem[1], ram.mem[32768], ram.mem[65535] in GTKWave.
Verify writes to 0, 1, 32768, 65535 and dout values in test phases.



License
MIT License.