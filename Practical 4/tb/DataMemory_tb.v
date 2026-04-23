// =============================================================================
// EEE4120F Practical 4 — StarCore-1 Processor
// File        : DataMemory_tb.v
// Description : Testbench for the Data Memory module (Task 4).
//               Verifies synchronous write, gated combinational read,
//               write followed by immediate read, and disabled-write safety.
//
// Run:
//   iverilog -Wall -I ../src -o ../build/dm_sim ../src/DataMemory.v DataMemory_tb.v
//   cd ../test && ../build/dm_sim
//   gtkwave ../waves/dm_tb.vcd &
// =============================================================================

`timescale 1ns / 1ps
`include "../src/Parameter.v"

module DataMemory_tb;

    reg        clk;
    reg  [15:0] mem_access_addr;
    reg  [15:0] mem_write_data;
    reg        mem_write_en;
    reg        mem_read;
    wire [15:0] mem_read_data;

    DataMemory uut (
        .clk             (clk),
        .mem_access_addr (mem_access_addr),
        .mem_write_data  (mem_write_data),
        .mem_write_en    (mem_write_en),
        .mem_read        (mem_read),
        .mem_read_data   (mem_read_data)
    );

    initial clk = 1'b0;
    always  #5 clk = ~clk;

    initial begin
        $dumpfile("../waves/dm_tb.vcd");
        $dumpvars(0, DataMemory_tb);
    end

    integer fail_count;
    integer test_id;
    integer i;              // general-purpose loop counter

    // -------------------------------------------------------------------------
    // Known contents of test.data (one 16-bit binary word per line, 8 lines).
    // These must match the values you placed in ../test/test.data.
    // -------------------------------------------------------------------------
    reg [15:0] init_vals  [0:7];   // expected values after $readmemb
    reg [15:0] write_vals [0:7];   // new values written in Group 2

    initial begin
        // Must match test.data lines 0–7
        init_vals[0] = 16'h0001;  init_vals[1] = 16'h0002;
        init_vals[2] = 16'h0003;  init_vals[3] = 16'h0004;
        init_vals[4] = 16'h0005;  init_vals[5] = 16'h0006;
        init_vals[6] = 16'h0007;  init_vals[7] = 16'h0008;

        // Distinct patterns used for write-then-read tests
        write_vals[0] = 16'hABCD;  write_vals[1] = 16'hDABC;
        write_vals[2] = 16'hCDAB;  write_vals[3] = 16'hBCDA;
        write_vals[4] = 16'hAABB;  write_vals[5] = 16'hBAAB;
        write_vals[6] = 16'hBBAA;  write_vals[7] = 16'hCCDD;
    end

    // =========================================================================
    // Helper task: check mem_read_data against an expected value and report.
    // =========================================================================
    task check;
        input [15:0] expected;
        input [15:0] addr_disp;   // just for the display message
        begin
            if (mem_read_data !== expected) begin
                $display("FAIL [T%0d]: addr=%0d  got=0x%h  exp=0x%h",
                         test_id, addr_disp, mem_read_data, expected);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS [T%0d]: addr=%0d", test_id, addr_disp);
            end
            test_id = test_id + 1;
        end
    endtask

    // =========================================================================
    // Main stimulus
    // =========================================================================
    initial begin
        fail_count      = 0;
        test_id         = 1;
        mem_write_en    = 1'b0;
        mem_read        = 1'b0;
        mem_access_addr = 16'd0;
        mem_write_data  = 16'd0;

        $display("=== DataMemory Testbench ===");

        // ------------------------------------------------------------------
        // TEST GROUP 1: Read back initial values loaded from test.data
        // ------------------------------------------------------------------
        // Strategy: assert mem_read, walk through all 8 addresses, and
        // compare the combinational output against the known init_vals[].
        // A simple #5 propagation delay is enough since reads are
        // combinational — no clock edge is needed.
        // ------------------------------------------------------------------
        $display("--- Group 1: Verify $readmemb initialisation ---");

        mem_read = 1'b1;

        for (i = 0; i < 8; i = i + 1) begin
            mem_access_addr = i;        // lower 3 bits select the word
            #5;                         // let the combinational output settle
            check(init_vals[i], i);
        end

        mem_read = 1'b0;

        // ------------------------------------------------------------------
        // TEST GROUP 2: Write new values to all 8 locations, then read back
        // ------------------------------------------------------------------
        // Strategy: for each address —
        //   1. Set up addr + data, assert write_en.
        //   2. Wait for posedge clk (the synchronous write happens here).
        //   3. Add #1 to step into the next timestep, avoiding the Icarus
        //      race between the testbench's deassert and the DUT's always
        //      block sampling write_en.
        //   4. Deassert write_en, then assert mem_read and check.
        // ------------------------------------------------------------------
        $display("--- Group 2: Write then read all 8 locations ---");

        for (i = 0; i < 8; i = i + 1) begin
            // --- Write ---
            mem_write_en    = 1'b1;
            mem_access_addr = i;
            mem_write_data  = write_vals[i];
            @(posedge clk); #1;         // let the flip-flop capture the write
            mem_write_en    = 1'b0;

            // --- Read back ---
            mem_read = 1'b1;
            #5;
            check(write_vals[i], i);
            mem_read = 1'b0;
        end

        // ------------------------------------------------------------------
        // TEST GROUP 3: mem_read = 0 must produce 16'd0 output
        // ------------------------------------------------------------------
        // Strategy: keep mem_read de-asserted and verify the output is
        // exactly 16'd0 for every address, regardless of stored content.
        // ------------------------------------------------------------------
        $display("--- Group 3: mem_read disabled -> output must be 0 ---");

        mem_read = 1'b0;

        for (i = 0; i < 8; i = i + 1) begin
            mem_access_addr = i;
            #5;
            if (mem_read_data !== 16'd0) begin
                $display("FAIL [T%0d]: addr=%0d  mem_read=0 but output=0x%h",
                         test_id, i, mem_read_data);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS [T%0d]: addr=%0d  output=0x0000 when mem_read=0",
                         test_id, i);
            end
            test_id = test_id + 1;
        end

        // ------------------------------------------------------------------
        // TEST GROUP 4: Write then immediately read on the next cycle
        // ------------------------------------------------------------------
        // Strategy: write 0xABCD to address 3, then on the very next cycle
        // (after the write has settled) assert mem_read at address 3 and
        // confirm the new value is returned.  This specifically tests that
        // there is no extra pipeline latency between a write and a read.
        // ------------------------------------------------------------------
        $display("--- Group 4: Write followed by immediate read ---");

        // Write 0xABCD to address 3
        mem_write_en    = 1'b1;
        mem_access_addr = 16'd3;
        mem_write_data  = 16'hABCD;
        @(posedge clk); #1;             // write captured on this edge
        mem_write_en    = 1'b0;

        // Read back immediately (same cycle, next half-period)
        mem_read        = 1'b1;
        mem_access_addr = 16'd3;
        #5;
        check(16'hABCD, 16'd3);
        mem_read = 1'b0;

        // ------------------------------------------------------------------
        // TEST GROUP 5: Disabled write must not alter memory
        // ------------------------------------------------------------------
        // Strategy:
        //   1. Write a known value to address 5 with write_en = 1.
        //   2. Keep write_en = 0 and put a *different* value on
        //      mem_write_data; clock one cycle.
        //   3. Read address 5 and confirm it still holds the original value.
        //      If write_en gating is broken the memory would be overwritten.
        // ------------------------------------------------------------------
        $display("--- Group 5: mem_write_en=0 must not overwrite memory ---");

        // Step 1: valid write to address 5
        mem_write_en    = 1'b1;
        mem_access_addr = 16'd5;
        mem_write_data  = 16'hBEEF;
        @(posedge clk); #1;
        mem_write_en    = 1'b0;

        // Step 2: attempt overwrite with write_en disabled
        mem_write_data  = 16'hDEAD;    // different value on the data bus
        mem_access_addr = 16'd5;
        @(posedge clk); #1;            // clock ticks but write_en = 0, no write

        // Step 3: read back — must still see 0xBEEF
        mem_read        = 1'b1;
        mem_access_addr = 16'd5;
        #5;
        check(16'hBEEF, 16'd5);
        mem_read = 1'b0;

        // ------------------------------------------------------------------
        // Summary
        // ------------------------------------------------------------------
        $display("");
        if (fail_count == 0)
            $display("=== ALL %0d TESTS PASSED ===", test_id - 1);
        else
            $display("=== %0d / %0d TESTS FAILED ===", fail_count, test_id - 1);
        $finish;
    end

endmodule
