transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {}
vlib activehdl/xilinx_vip
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/xil_defaultlib
vlib activehdl/axi_vip_v1_1_14

vlog -work xilinx_vip  -sv2k12 "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ipstatic/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ip/axi_vip_1/sim/axi_vip_1_pkg.sv" \

vlog -work axi_vip_v1_1_14  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ipstatic/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic/hdl" "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_14 \
"../../../ip/axi_vip_1/sim/axi_vip_1.sv" \

vlog -work xil_defaultlib \
"glbl.v"

