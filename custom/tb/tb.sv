//------------------------------------------------------------------------------
// TB: new_axi_sig_gen_v6 with Xilinx AXI VIP master for AXI-Lite
//------------------------------------------------------------------------------

`timescale 1ns/1ps

import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb_new_axi_sig_gen_v6;

  // ------------------------------
  // DUT parameters (tweak as needed)
  // ------------------------------
  localparam int N      = 10;
  localparam int N_DDS  = 4;

  // ------------------------------
  // AXI-Lite signals (to DUT) + VIP
  // ------------------------------
  reg                s_axi_aclk;
  reg                s_axi_aresetn;

  wire [5:0]         s_axi_araddr;
  wire [2:0]         s_axi_arprot;
  wire               s_axi_arready;
  wire               s_axi_arvalid;
  wire [5:0]         s_axi_awaddr;
  wire [2:0]         s_axi_awprot;
  wire               s_axi_awready;
  wire               s_axi_awvalid;
  wire               s_axi_bready;
  wire [1:0]         s_axi_bresp;
  wire               s_axi_bvalid;
  wire [31:0]        s_axi_rdata;
  wire               s_axi_rready;
  wire [1:0]         s_axi_rresp;
  wire               s_axi_rvalid;
  wire [31:0]        s_axi_wdata;
  wire               s_axi_wready;
  wire [3:0]         s_axi_wstrb;
  wire               s_axi_wvalid;

  // ------------------------------
  // s0_axis: load table memory
  // ------------------------------
  reg                s0_axis_aclk;
  reg                s0_axis_aresetn;
  reg  [31:0]        s0_axis_tdata;
  wire               s0_axis_tready;
  reg                s0_axis_tvalid;

  // ------------------------------
  // Common data clock/reset (s1/m)
  // ------------------------------
  reg                aclk;
  reg                aresetn;

  // Optional faster toggle helper for plotting loop
  reg                aclk4;

  // ------------------------------
  // s1_axis: queue waveforms (160b descriptor)
  // ------------------------------
  reg  [159:0]       s1_axis_tdata;
  wire               s1_axis_tready;
  reg                s1_axis_tvalid;

  // ------------------------------
  // m_axis: DUT output
  // ------------------------------
  wire [N_DDS*16-1:0] m_axis_tdata;
  reg                 m_axis_tready = 1'b1;
  wire                m_axis_tvalid;

  // ------------------------------
  // Waveform descriptor fields (packed into s1_axis_tdata)
  // ------------------------------
  reg  [31:0]        freq_r;
  reg  [31:0]        phase_r;
  reg  [15:0]        addr_r;
  reg  [15:0]        gain_r;
  reg  [15:0]        nsamp_r;
  reg  [1:0]         outsel_r;
  reg                mode_r;
  reg                stdysel_r;
  reg                phrst_r;

  // Debug view of m_axis_tdata
  wire [15:0]        dout_ii [0:N_DDS-1];
  reg  [15:0]        dout_f;

  // ------------------------------
  // AXI VIP master (AXI4-Lite)
  // NOTE: These addresses assume the VIP uses 0x4000_0000 base then
  // DUT only decodes low 6 bits; adjust if your address map differs.
  // ------------------------------
  xil_axi_ulong      addr_start_addr = 32'h4000_0000; // write -> 6'h00
  xil_axi_ulong      addr_we         = 32'h4000_0004; // write -> 6'h01*4

  xil_axi_prot_t     prot            = 0;
  reg  [31:0]        data_wr;
  reg  [31:0]        data_rd;
  xil_axi_resp_t     resp;

  // TB flow control
  reg  tb_load_mem       = 0;
  reg  tb_load_mem_done  = 0;
  reg  tb_load_wave      = 0;
  reg  tb_load_wave_done = 0;
  reg  tb_write_out      = 0;

  // Map each 16b lane
  genvar ii;
  generate
    for (ii = 0; ii < N_DDS; ii++) begin : GEN_DEBUG
      assign dout_ii[ii] = m_axis_tdata[16*ii +: 16];
    end
  endgenerate

  // Instantiate Xilinx AXI VIP (generated IP “axi_mst_0”)
  axi_mst_0 axi_mst_0_i (
    .aclk          (s_axi_aclk),
    .aresetn       (s_axi_aresetn),
    .m_axi_araddr  (s_axi_araddr),
    .m_axi_arprot  (s_axi_arprot),
    .m_axi_arready (s_axi_arready),
    .m_axi_arvalid (s_axi_arvalid),
    .m_axi_awaddr  (s_axi_awaddr),
    .m_axi_awprot  (s_axi_awprot),
    .m_axi_awready (s_axi_awready),
    .m_axi_awvalid (s_axi_awvalid),
    .m_axi_bready  (s_axi_bready),
    .m_axi_bresp   (s_axi_bresp),
    .m_axi_bvalid  (s_axi_bvalid),
    .m_axi_rdata   (s_axi_rdata),
    .m_axi_rready  (s_axi_rready),
    .m_axi_rresp   (s_axi_rresp),
    .m_axi_rvalid  (s_axi_rvalid),
    .m_axi_wdata   (s_axi_wdata),
    .m_axi_wready  (s_axi_wready),
    .m_axi_wstrb   (s_axi_wstrb),
    .m_axi_wvalid  (s_axi_wvalid)
  );

  // ------------------------------
  // DUT: your new wrapper
  // Make sure port names match your wrapper. If your wrapper names differ,
  // rename below accordingly.
  // ------------------------------
  new_axi_sig_gen_v6 #(
    .N              (N),
    .N_DDS          (N_DDS),
    .GEN_DDS        ("FALSE"),
    .ENVELOPE_TYPE  ("REAL")
  ) DUT (
    // AXI-Lite
    .s_axi_aclk     (s_axi_aclk),
    .s_axi_aresetn  (s_axi_aresetn),
    .s_axi_araddr   (s_axi_araddr),
    .s_axi_arprot   (s_axi_arprot),
    .s_axi_arready  (s_axi_arready),
    .s_axi_arvalid  (s_axi_arvalid),
    .s_axi_awaddr   (s_axi_awaddr),
    .s_axi_awprot   (s_axi_awprot),
    .s_axi_awready  (s_axi_awready),
    .s_axi_awvalid  (s_axi_awvalid),
    .s_axi_bready   (s_axi_bready),
    .s_axi_bresp    (s_axi_bresp),
    .s_axi_bvalid   (s_axi_bvalid),
    .s_axi_rdata    (s_axi_rdata),
    .s_axi_rready   (s_axi_rready),
    .s_axi_rresp    (s_axi_rresp),
    .s_axi_rvalid   (s_axi_rvalid),
    .s_axi_wdata    (s_axi_wdata),
    .s_axi_wready   (s_axi_wready),
    .s_axi_wstrb    (s_axi_wstrb),
    .s_axi_wvalid   (s_axi_wvalid),

    // s0_axis: load memory
    .s0_axis_aclk    (s0_axis_aclk),
    .s0_axis_aresetn (s0_axis_aresetn),
    .s0_axis_tdata   (s0_axis_tdata),
    .s0_axis_tvalid  (s0_axis_tvalid),
    .s0_axis_tready  (s0_axis_tready),

    // common data clock/reset
    .aclk            (aclk),
    .aresetn         (aresetn),

    // s1_axis: queue waveforms
    .s1_axis_tdata   (s1_axis_tdata),
    .s1_axis_tvalid  (s1_axis_tvalid),
    .s1_axis_tready  (s1_axis_tready),

    // m_axis: output
    .m_axis_tready   (m_axis_tready),
    .m_axis_tvalid   (m_axis_tvalid),
    .m_axis_tdata    (m_axis_tdata)
  );

  // ------------------------------
  // VIP Agent handle
  // ------------------------------
  axi_mst_0_mst_t axi_mst_0_agent;

  // Pack the 160-bit s1 descriptor
  assign s1_axis_tdata = {
    {10{1'b0}},          // pad to 160b
    phrst_r,             // 1
    stdysel_r,           // 1
    mode_r,              // 1
    outsel_r,            // 2
    nsamp_r,             // 16
    {16{1'b0}},          // pad
    gain_r,              // 16
    {16{1'b0}},          // pad
    addr_r,              // 16
    phase_r,             // 32
    freq_r               // 32
  };

  // ------------------------------
  // Main control / AXI-Lite programming
  // ------------------------------
  initial begin
    // Create & start VIP agent
    axi_mst_0_agent = new("axi_mst_0 VIP Agent", tb_new_axi_sig_gen_v6.axi_mst_0_i.inst.IF);
    axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");
    axi_mst_0_agent.start_master();

    // Resets
    s_axi_aresetn     <= 1'b0;
    s0_axis_aresetn   <= 1'b0;
    aresetn           <= 1'b0;
    repeat (25) @(posedge s_axi_aclk); // ~500ns at 100MHz
    s_axi_aresetn     <= 1'b1;
    s0_axis_aresetn   <= 1'b1;
    aresetn           <= 1'b1;

    // Wait a bit for DUT to settle
    repeat (50) @(posedge s_axi_aclk);

    // ------------------------------
    // Example AXI-Lite programming
    // ------------------------------
    $display("[%0t] ### Program DUT registers (start_addr, we) ###", $time);
    data_wr = 32'd0;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_start_addr, prot, data_wr, resp);
    if (resp != AXI_OKAY) $display("[%0t] WARN: start_addr write resp=%0d", $time, resp);

    data_wr = 32'd1;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_we, prot, data_wr, resp);
    if (resp != AXI_OKAY) $display("[%0t] WARN: we write resp=%0d", $time, resp);

    // Kick s0 loader
    tb_load_mem <= 1'b1;
    wait (tb_load_mem_done);
    tb_load_mem <= 1'b0;

    // Deassert WE
    data_wr = 32'd0;
    axi_mst_0_agent.AXI4LITE_WRITE_BURST(addr_we, prot, data_wr, resp);

    // Queue waveforms (+ start dumping output)
    $display("[%0t] ### Queue Waveforms & Capture Output ###", $time);
    tb_write_out <= 1'b1;
    tb_load_wave <= 1'b1;
    wait (tb_load_wave_done);
    tb_load_wave <= 1'b0;

    // Allow some runtime
    #10us;
    tb_write_out <= 1'b0;

    $display("[%0t] Finished. Stopping sim.", $time);
    $finish;
  end

  // ------------------------------
  // s0 loader: read ./gauss.txt into s0_axis
  // ------------------------------
  initial begin : LOAD_S0
    int fd, vali, valq;
    bit signed [15:0] ii, qq;

    s0_axis_tvalid   <= 1'b0;
    s0_axis_tdata    <= '0;

    wait (tb_load_mem);
    fd = $fopen("./gauss.txt", "r");
    if (fd == 0) begin
      $display("[%0t] WARN: ./gauss.txt not found; generating a few zeros", $time);
      repeat (8) begin
        @(posedge s0_axis_aclk);
        if (s0_axis_tready) begin
          s0_axis_tvalid <= 1'b1;
          s0_axis_tdata  <= 32'h0000_0000;
        end
      end
      @(posedge s0_axis_aclk);
      s0_axis_tvalid <= 1'b0;
      tb_load_mem_done <= 1'b1;
      disable LOAD_S0;
    end

    // Wait until DUT ready then stream all samples
    wait (s0_axis_tready);
    while ($fscanf(fd, "%d,%d", vali, valq) == 2) begin
      ii = vali; qq = valq;
      @(posedge s0_axis_aclk);
      s0_axis_tvalid <= 1'b1;
      s0_axis_tdata  <= {qq, ii};
    end

    @(posedge s0_axis_aclk);
    s0_axis_tvalid <= 1'b0;
    $fclose(fd);
    tb_load_mem_done <= 1'b1;
  end

  // ------------------------------
  // s1 loader: push a few descriptors
  // ------------------------------
  initial begin
    s1_axis_tvalid <= 1'b0;
    freq_r   <= '0; phase_r <= '0; addr_r  <= '0;
    gain_r   <= '0; nsamp_r <= '0; outsel_r<= '0;
    mode_r   <= 1'b0; stdysel_r <= 1'b0; phrst_r <= 1'b0;

    wait (tb_load_wave);
    wait (s1_axis_tready);

    // Example 1: outsel=0 (prod)
    @(posedge aclk);
    s1_axis_tvalid <= 1'b1;
    freq_r   <= freq_calc(0, N_DDS, 4);
    phase_r  <= 32'd0;
    addr_r   <= 16'd22;
    gain_r   <= 16'd12000;
    nsamp_r  <= 16'd80;
    outsel_r <= 2'd0;
    mode_r   <= 1'b0;
    stdysel_r<= 1'b0;
    phrst_r  <= 1'b0;

    #5us;

    // Example 2: outsel=1 (dds)
    @(posedge aclk);
    s1_axis_tvalid <= 1'b1;
    outsel_r <= 2'd1;

    #5us;

    // Example 3: outsel=2 (mem)
    @(posedge aclk);
    s1_axis_tvalid <= 1'b1;
    outsel_r <= 2'd2;

    #5us;

    @(posedge aclk);
    s1_axis_tvalid <= 1'b0;
    tb_load_wave_done <= 1'b1;
  end

  // ------------------------------
  // Output capture: CSV dump
  // ------------------------------
  initial begin
    int fd;
    int i;
    shortint real_d;

    fd = $fopen("./dout.csv", "w");
    $fdisplay(fd, "valid, idx, real");

    wait (tb_write_out);
    while (tb_write_out) begin
      @(posedge aclk);
      for (i = 0; i < N_DDS; i++) begin
        real_d = dout_ii[i][15:0];
        $fdisplay(fd, "%0d, %0d, %0d", m_axis_tvalid, i, real_d);
      end
    end

    $display("[%0t] Closing dout.csv", $time);
    $fclose(fd);
  end

  // ------------------------------
  // Optional plotting helper (not essential)
  // ------------------------------
  initial begin
    dout_f <= '0;
    @(posedge aclk);
    forever begin
      for (int k = 0; k < N_DDS; k++) begin
        @(posedge aclk4);
        dout_f = dout_ii[k];
      end
    end
  end

  // ------------------------------
  // Clocks (simple)
  // ------------------------------
  always begin s_axi_aclk   <= 1'b0; #10; s_axi_aclk   <= 1'b1; #10; end  // 50 MHz
  always begin s0_axis_aclk <= 1'b0; #10; s0_axis_aclk <= 1'b1; #10; end  // 50 MHz

  // aclk + aclk4 helper
  always begin
    aclk  <= 1'b0;
    aclk4 <= 1'b0; #1; aclk4 <= 1'b1; #1; aclk4 <= 1'b0; #1; aclk4 <= 1'b1; #1;
    aclk  <= 1'b1;
    aclk4 <= 1'b0; #1; aclk4 <= 1'b1; #1; aclk4 <= 1'b0; #1; aclk4 <= 1'b1; #1;
  end

  // ------------------------------
  // Frequency helper (same as your QICK TB)
  //   fclk in MHz, ndds = N_DDS, f in MHz
  // ------------------------------
  function automatic [31:0] freq_calc(input int fclk, input int ndds, input int f);
    real fs, temp;
    fs        = fclk * ndds;
    temp      = f / fs * 2.0**30;
    freq_calc = {int'(temp), 2'b00};
  endfunction

endmodule
