`timescale 1ns/1ps

module tb_new_axi_sig_gen;

  // ------------------------------------------------------------
  // Parameters
  // ------------------------------------------------------------
  localparam int N_DDS = 16;
  localparam int M_DATA_W = N_DDS*16;

  // ------------------------------------------------------------
  // Clocks and resets
  // ------------------------------------------------------------
  logic t_clk, s_axi_clk, s0_axi_clk, aclk;
  logic t_resetn, s_resetn;

  initial begin
    t_clk = 0;
    forever #5 t_clk = ~t_clk;   // 100 MHz
  end

  initial begin
    s_axi_clk = 0;
    forever #7 s_axi_clk = ~s_axi_clk; // ~71 MHz
  end

  initial begin
    s0_axi_clk = 0;
    forever #11 s0_axi_clk = ~s0_axi_clk; // ~45 MHz
  end

  initial begin
    aclk = 0;
    forever #13 aclk = ~aclk; // ~38 MHz
  end

  initial begin
    t_resetn = 0;
    s_resetn = 0;
    #100;
    t_resetn = 1;
    s_resetn = 1;
  end

  // ------------------------------------------------------------
  // Interfaces
  // ------------------------------------------------------------
  // Control plane: TP drives as AXI-Lite master
  AXI_BUS #(
    .AXI_ADDR_WIDTH(6),
    .AXI_DATA_WIDTH(32),
    .AXI_ID_WIDTH  (0),
    .AXI_USER_WIDTH(0)
  ) tp_axi_ctrl();

  // AXIS data interfaces
  taxi_axis_if #(.DATA_W(32))   tp_s0_axis();
  taxi_axis_if #(.DATA_W(160))  tp_s1_axis();
  taxi_axis_if #(.DATA_W(M_DATA_W)) tp_m_axis();

  // ------------------------------------------------------------
  // DUT
  // ------------------------------------------------------------
  new_axi_sig_gen #(
    .N_DDS(N_DDS)
  ) dut (
    .t_clk      (t_clk),
    .s_axi_clk  (s_axi_clk),
    .s0_axi_clk (s0_axi_clk),
    .aclk       (aclk),
    .t_resetn   (t_resetn),
    .s_resetn   (s_resetn),
    .tp_axi_ctrl(tp_axi_ctrl),
    .tp_s0_axis (tp_s0_axis),
    .tp_s1_axis (tp_s1_axis),
    .tp_m_axis  (tp_m_axis)
  );

  // ------------------------------------------------------------
  // Simple AXI-Lite write task
  // ------------------------------------------------------------
  task axi_lite_write(input [5:0] addr, input [31:0] data);
    begin
      // drive write address
      tp_axi_ctrl.aw_addr  <= addr;
      tp_axi_ctrl.aw_valid <= 1;
      // drive write data
      tp_axi_ctrl.w_data   <= data;
      tp_axi_ctrl.w_strb   <= 4'hF;
      tp_axi_ctrl.w_valid  <= 1;

      @(posedge s_axi_clk);
      wait(tp_axi_ctrl.aw_ready && tp_axi_ctrl.w_ready);

      tp_axi_ctrl.aw_valid <= 0;
      tp_axi_ctrl.w_valid  <= 0;

      // wait for write response
      wait(tp_axi_ctrl.b_valid);
      tp_axi_ctrl.b_ready <= 1;
      @(posedge s_axi_clk);
      tp_axi_ctrl.b_ready <= 0;
    end
  endtask

  // ------------------------------------------------------------
  // Stimulus
  // ------------------------------------------------------------
  initial begin
    // Wait for reset release
    wait(t_resetn && s_resetn);
    @(posedge t_clk);

    // Do a simple AXI-Lite write to configure START_ADDR_REG
    axi_lite_write(6'h00, 32'h12345678);

    // Push a few samples into s0_axis
    repeat (4) begin
      tp_s0_axis.tdata  <= 8'h55;
      tp_s0_axis.tvalid <= 1;
      @(posedge t_clk);
      wait(tp_s0_axis.tready);
      tp_s0_axis.tvalid <= 0;
    end

    // Push a few waveforms into s1_axis
    repeat (2) begin
      tp_s1_axis.tdata  <= 8'hb3;
      tp_s1_axis.tvalid <= 1;
      @(posedge t_clk);
      wait(tp_s1_axis.tready);
      tp_s1_axis.tvalid <= 0;
    end

    // Observe m_axis output for a while
    repeat (20) begin
      @(posedge t_clk);
      if (tp_m_axis.tvalid) begin
        $display("Time %0t: Got m_axis data = %h", $time, tp_m_axis.tdata);
        tp_m_axis.tready <= 1;
        $stop;
      end else begin
        tp_m_axis.tready <= 0;
      end
    end

    $finish;
  end

endmodule
