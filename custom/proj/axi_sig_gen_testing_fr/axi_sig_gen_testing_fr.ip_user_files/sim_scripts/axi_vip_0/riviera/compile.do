transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {/home/hrlclinic/Documents/troy_axi_sig_gen/axi_sig_gen_testing_fr/axi_sig_gen_testing_fr.cache/compile_simlib/riviera}
vlib riviera/xilinx_vip
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/xil_defaultlib
vlib riviera/axi_vip_v1_1_14

vlog -work xilinx_vip  -incr "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../../axi_sig_gen_testing_fr.gen/sources_1/ip/axi_vip_0/sim/axi_vip_0_pkg.sv" \

vlog -work axi_vip_v1_1_14  -incr "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ipstatic/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../../axi_sig_gen_testing_fr.gen/sources_1/ip/axi_vip_0/sim/axi_vip_0.sv" \

vlog -work xil_defaultlib \
"glbl.v"

