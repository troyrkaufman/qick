vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/axi_vip_v1_1_14

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap axi_vip_v1_1_14 questa_lib/msim/axi_vip_v1_1_14

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_14 -L xilinx_vip "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" \
"../../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_14 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" \
"../../../ip/axi_vip_2/sim/axi_vip_2_pkg.sv" \

vlog -work axi_vip_v1_1_14 -64 -incr -mfcu  -sv -L axi_vip_v1_1_14 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" \
"../../../ipstatic/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_14 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" \
"../../../ip/axi_vip_2/sim/axi_vip_2.sv" \

vlog -work xil_defaultlib \
"glbl.v"

