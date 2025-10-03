# RAM8x64K Verilog — README

A small Verilog project implementing a synchronous **8-bit × 64K (65,536 addresses)** RAM (`ram8x64k`) and a self-checking testbench (`tb_ram8x64k`). The testbench writes a small 16×16 pattern, checks boundary and random addresses, compares memory against the golden matrix and optionally dumps a waveform and debug prints.

---

## Files

* `ram8x64k.v` — RAM module (synchronous write & synchronous read).
* `tb_ram8x64k.v` — Testbench (MATRIX_SIZE = 16 by default). Writes/reads, self-checks, produces messages, and creates a VCD waveform.
* `ramWave.vcd` — Waveform output (created when the sim runs).
* `README.md` — this file.

> Note: the code you provided uses `reg [7:0] mem [0:65535];` so the memory size is 64 KB and addresses are 16 bits.

---

## Behavior summary / timing

* **Address width:** 16 bits → 0..65535
* **Data width:** 8 bits
* **Write behavior:** synchronous — on `posedge clk`, if `we` is `1`, `mem[addr] <= din`.
* **Read behavior:** synchronous — on `posedge clk`, if `we` is `0`, `dout <= mem[addr]`.
  (So both read and write update output/memory only on rising clock edges.)

---

## How to build & run

Below are simple commands for **Icarus Verilog** (`iverilog` + `vvp`) — recommended for quick simulation.

### 1) Compile

From the project directory:

```bash
# using Verilog-2001 / SystemVerilog features just in case, but -g2012 is safe
iverilog -o sim_ram8x64k tb_ram8x64k.v ram8x64k.v
```

To enable `DEBUG` prints that are guarded by `` `ifdef DEBUG `` you can either:

* Uncomment the ``//`define DEBUG`` line at the top of the testbench, or
* Pass a macro define at compile:

```bash
iverilog -o sim_ram8x64k tb_ram8x64k.v ram8x64k.v
```

### 2) Run simulation

```bash
vvp sim_ram8x64k
```

This will run the testbench, print test pass/fail messages to the console, and create `ramWave.vcd` (waveform).

### 3) View waveform (optional)

Open the generated VCD in GTKWave:

```bash
gtkwave ramWave.vcd
```

The testbench calls:

```verilog
$dumpfile("ramWave.vcd");
$dumpvars(0, tb_ram8x64k, ram);
```

so the top-level testbench signals and several memory entries are dumped.

---

## Expected console output

When everything passes, you should see something similar to:

```
Testing Boundary Addresses: Passed
Testing Random Addresses: Passed
Comparison Phase: Passed
```

If a check fails you'll see messages such as:

```
Failed
Error at addr 65535: expected 255, got 0
```

or

```
Failed
Error at addr 512 (row 2, col 0): expected 1, got 0
```

> The testbench reads original values at addresses `65535` and `32768` before changing them, then restores them. Because `mem` is not explicitly initialized, simulation tools may show `x` for uninitialized memory. The testbench reads and preserves whatever value was there.

---

## What the testbench does (step-by-step)

1. Generates a clock (`always #5 clk = ~clk;`) → 10 ns period.
2. Fills a `MATRIX_SIZE × MATRIX_SIZE` area (default 16×16) with the pattern: rows with odd index → `1`, rows with even index → `0`.
3. Tests the boundary address `65535` — writes `255` and verifies. Restores previous value.
4. Tests an arbitrary mid address, `32768` — writes `128` and verifies. Restores previous value.
5. Compares all written `MATRIX_SIZE × MATRIX_SIZE` locations against `goldenRam`.
6. If `` `define DEBUG`` is active (or `-DDEBUG` at compile), prints RAM contents and `goldenRam` to console.
7. Dumps VCD and finishes.

---

## How to change behavior

* **Matrix size:** edit the `parameter MATRIX_SIZE = 16;` in `tb_ram8x64k.v`. Keep it small for quick sims; larger sizes increase runtime.
* **Change addresses tested:** modify `addr = 65535;` and `addr = 32768;` in the testbench.
* **Enable verbose debug prints:** uncomment ``//`define DEBUG`` or compile with `-DDEBUG`.

---

## Notes, tips & troubleshooting

* If the simulator prints `x` values: memory is uninitialized by default. The testbench preserves/read original values for the two non-pattern addresses to avoid losing whatever was there. For deterministic sims, initialize memory before use (e.g., add an initialization loop or `$readmemh` if desired).
* If `ramWave.vcd` is not produced, ensure the testbench reaches the `$dumpfile/$dumpvars` lines (they are in the initial block in your TB). Also ensure your simulator supports VCD (Icarus does).
* For ModelSim/Questa use `vlog` and `vsim` similarly; for other tools adapt compile/run commands accordingly.
* If you use Verilator regularly and want a C++ harness, you can convert the testbench into a C++ test harness that toggles signals and use Verilator to build; this is more advanced (not required to run the provided `.v` TB).

---

## Short example (copy/paste)

```bash
# compile
iverilog -o sim_ram8x64k tb_ram8x64k.v ram8x64k.v

# run
vvp sim_ram8x64k

# view waveform
gtkwave ramWave.vcd
```

With DEBUG:

```bash
iverilog -g2012 -DDEBUG -o sim_ram8x64k tb_ram8x64k.v ram8x64k.v
vvp sim_ram8x64k
```

---

## License

MIT
