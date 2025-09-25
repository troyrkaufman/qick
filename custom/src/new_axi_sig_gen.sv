`include "axi/typedef.svh"
`include "axi/assign.svh"

// Top-level wrapper that bridges a timed processor (TP) to axis_signal_gen_v6
// via AXI4-Lite CDC (control) and AXI4-Stream async FIFOs (data).
module new_axi_sig_gen #(
  // Match axis_signal_gen_v6 defaults; override if you change the DUT
  parameter int unsigned N_DDS = 16
)(
  // ------------------------
  // Clocks / resets
  // ------------------------
  input  logic        t_clk,        // TP domain clock
  input  logic        t_resetn,     // TP domain reset (active-low)

  input  logic        s_axi_clk,    // SigGen AXI-Lite clock (control)
  input  logic        s0_axi_clk,    // SigGen s0 AXIS clock (sample loader)
  input  logic        aclk,          // SigGen s1 + m_axis clock (datapath)
  input  logic        s_resetn,      // SigGen resets (active-low)

  // ------------------------
  // TP-side CONTROL (AXI4-Lite)
  // The wrapper is an AXI-Lite SLAVE to the TP master.
  // Widths MUST match the SigGen: addr=6, data=32, no IDs/USER.
  // ------------------------
  AXI_BUS.Slave      tp_axi_ctrl,

  // ------------------------
  // TP-side DATA (AXI4-Stream)
  // - s0: TP is a SOURCE feeding the SigGen sample loader (DATA_W=32)
  // - s1: TP is a SOURCE feeding the SigGen waveform queue (DATA_W=160)
  // - m : TP is a SINK  consuming the SigGen output      (DATA_W=N_DDS*16)
  // Instantiate these taxi_axis_if on the TP side with matching DATA_W.
  // ------------------------
  taxi_axis_if       tp_s0_axis,     // DATA_W must be 32
  taxi_axis_if       tp_s1_axis,     // DATA_W must be 160
  taxi_axis_if       tp_m_axis       // DATA_W must be N_DDS*16
);

  // ------------------------------------------------------------
  // 1) AXI4-Lite CDC (control plane) TP -> SigGen s_axi_*
  // ------------------------------------------------------------
  // SigGen-side AXI bus bundle (addr=6, data=32, id/user=0)
  AXI_BUS #(
    .AXI_ADDR_WIDTH (6),
    .AXI_DATA_WIDTH (32),
    .AXI_ID_WIDTH   (0),
    .AXI_USER_WIDTH (0)
  ) s_axi_if ();

  // Cross from TP domain (tp_axi_ctrl) to SigGen s_axi domain
  axi_cdc_intf #(
    .AXI_ID_WIDTH   (0),
    .AXI_ADDR_WIDTH (6),
    .AXI_DATA_WIDTH (32),
    .AXI_USER_WIDTH (0),
    .LOG_DEPTH      (2),
    .SYNC_STAGES    (2)
  ) i_axi_cdc_ctrl (
    // "src" = slave side (TP clock domain)
    .src_clk_i   (t_clk),
    .src_rst_ni  (t_resetn),
    .src         (tp_axi_ctrl),

    // "dst" = master side (SigGen clock domain)
    .dst_clk_i   (s_axi_clk),
    .dst_rst_ni  (s_resetn),
    .dst         (s_axi_if)
  );

  // ------------------------------------------------------------
  // 2) AXI-Stream async FIFOs (data plane)
  //    We insert interface stubs between FIFO and SigGen for wiring.
  // ------------------------------------------------------------

  // --- s0_axis path: TP (source @ t_clk) -> FIFO -> SigGen s0 (sink @ s0_axi_clk)
  taxi_axis_if #(.DATA_W(32))         s0_axis_to_siggen();

  taxi_axis_async_fifo #(
    .DEPTH(1024)
  ) i_fifo_s0 (
    // source side (TP clock domain)
    .s_clk        (t_clk),
    .s_rst        (~t_resetn),
    .s_axis       (tp_s0_axis),    // TP provides tdata/tvalid; gets tready

    // sink side (SigGen clock domain)
    .m_clk        (s0_axi_clk),
    .m_rst        (~s_resetn),
    .m_axis       (s0_axis_to_siggen),

    // Pause (unused)
    .s_pause_req  (1'b0),
    .s_pause_ack  (/*unused*/),
    .m_pause_req  (1'b0),
    .m_pause_ack  (/*unused*/),

    // Status (unused but handy to tap in sim)
    .s_status_depth         (),
    .s_status_depth_commit  (),
    .s_status_overflow      (),
    .s_status_bad_frame     (),
    .s_status_good_frame    (),
    .m_status_depth         (),
    .m_status_depth_commit  (),
    .m_status_overflow      (),
    .m_status_bad_frame     (),
    .m_status_good_frame    ()
  );

  // --- s1_axis path: TP (source @ t_clk) -> FIFO -> SigGen s1 (sink @ aclk)
  taxi_axis_if #(.DATA_W(160))        s1_axis_to_siggen();

  taxi_axis_async_fifo #(
    .DEPTH(1024)
  ) i_fifo_s1 (
    .s_clk        (t_clk),
    .s_rst        (~t_resetn),
    .s_axis       (tp_s1_axis),

    .m_clk        (aclk),
    .m_rst        (~s_resetn),
    .m_axis       (s1_axis_to_siggen),

    .s_pause_req  (1'b0),
    .s_pause_ack  (/*unused*/),
    .m_pause_req  (1'b0),
    .m_pause_ack  (/*unused*/),

    .s_status_depth         (),
    .s_status_depth_commit  (),
    .s_status_overflow      (),
    .s_status_bad_frame     (),
    .s_status_good_frame    (),
    .m_status_depth         (),
    .m_status_depth_commit  (),
    .m_status_overflow      (),
    .m_status_bad_frame     (),
    .m_status_good_frame    ()
  );

  // --- m_axis path: SigGen (source @ aclk) -> FIFO -> TP (sink @ t_clk)
  localparam int M_DATA_W = N_DDS*16;
  taxi_axis_if #(.DATA_W(M_DATA_W))   m_axis_from_siggen();

  taxi_axis_async_fifo #(
    .DEPTH(1024)
  ) i_fifo_m (
    .s_clk        (aclk),
    .s_rst        (~s_resetn),
    .s_axis       (m_axis_from_siggen),  // SigGen drives this side

    .m_clk        (t_clk),
    .m_rst        (~t_resetn),
    .m_axis       (tp_m_axis),           // TP consumes here

    .s_pause_req  (1'b0),
    .s_pause_ack  (/*unused*/),
    .m_pause_req  (1'b0),
    .m_pause_ack  (/*unused*/),

    .s_status_depth         (),
    .s_status_depth_commit  (),
    .s_status_overflow      (),
    .s_status_bad_frame     (),
    .s_status_good_frame    (),
    .m_status_depth         (),
    .m_status_depth_commit  (),
    .m_status_overflow      (),
    .m_status_bad_frame     (),
    .m_status_good_frame    ()
  );

  // ------------------------------------------------------------
  // 3) Signal Generator instance + flat wiring to interfaces
  // ------------------------------------------------------------
  axis_signal_gen_v6 #(
    .N         (12),
    .N_DDS     (N_DDS),
    .GEN_DDS   ("TRUE"),
    .ENVELOPE_TYPE("COMPLEX")
  ) i_siggen (
    // Control plane (AXI4-Lite after CDC)
    .s_axi_aclk     (s_axi_clk),
    .s_axi_aresetn  (s_resetn),

    .s_axi_awaddr   (s_axi_if.aw.addr),
    .s_axi_awprot   (s_axi_if.aw.prot),
    .s_axi_awvalid  (s_axi_if.aw.valid),
    .s_axi_awready  (s_axi_if.aw.ready),

    .s_axi_wdata    (s_axi_if.w.data),
    .s_axi_wstrb    (s_axi_if.w.strb),
    .s_axi_wvalid   (s_axi_if.w.valid),
    .s_axi_wready   (s_axi_if.w.ready),

    .s_axi_bresp    (s_axi_if.b.resp),
    .s_axi_bvalid   (s_axi_if.b.valid),
    .s_axi_bready   (s_axi_if.b.ready),

    .s_axi_araddr   (s_axi_if.ar.addr),
    .s_axi_arprot   (s_axi_if.ar.prot),
    .s_axi_arvalid  (s_axi_if.ar.valid),
    .s_axi_arready  (s_axi_if.ar.ready),

    .s_axi_rdata    (s_axi_if.r.data),
    .s_axi_rresp    (s_axi_if.r.resp),
    .s_axi_rvalid   (s_axi_if.r.valid),
    .s_axi_rready   (s_axi_if.r.ready),

    // AXIS s0 (sample loader) — flat ports wired to interface
    .s0_axis_aclk   (s0_axi_clk),
    .s0_axis_aresetn(s_resetn),
    .s0_axis_tdata  (s0_axis_to_siggen.tdata),
    .s0_axis_tvalid (s0_axis_to_siggen.tvalid),
    .s0_axis_tready (s0_axis_to_siggen.tready),

    // AXIS s1 (waveform queue)
    .aclk           (aclk),
    .aresetn        (s_resetn),
    .s1_axis_tdata  (s1_axis_to_siggen.tdata),
    .s1_axis_tvalid (s1_axis_to_siggen.tvalid),
    .s1_axis_tready (s1_axis_to_siggen.tready),

    // AXIS m (SigGen output) — drive the interface that feeds FIFO
    .m_axis_tready  (m_axis_from_siggen.tready),
    .m_axis_tvalid  (m_axis_from_siggen.tvalid),
    .m_axis_tdata   (m_axis_from_siggen.tdata)
  );

  // ----------------------------------------------------------------
  // Sanity checks (optional but recommended)
  // ----------------------------------------------------------------
  // Synthesis-time assertions to catch width mismatches early
  initial begin
    // AXI-Lite widths
    if (AXI_BUS'(.AXI_ADDR_WIDTH(6), .AXI_DATA_WIDTH(32))'(0) !== 0) begin end // dummy reference

    // AXIS data widths
    if (tp_s0_axis.DATA_W   != 32)
      $error("tp_s0_axis.DATA_W must be 32 to match s0_axis_tdata");
    if (tp_s1_axis.DATA_W   != 160)
      $error("tp_s1_axis.DATA_W must be 160 to match s1_axis_tdata");
    if (tp_m_axis.DATA_W    != (N_DDS*16))
      $error("tp_m_axis.DATA_W must be N_DDS*16 to match m_axis_tdata");
  end

endmodule
