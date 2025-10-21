transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {/home/hrlclinic/Documents/troy_axi_sig_gen/axi_sig_gen_testing_fr/axi_sig_gen_testing_fr.cache/compile_simlib/riviera}
vlib riviera/xilinx_vip
vlib riviera/xbip_utils_v3_0_10
vlib riviera/axi_utils_v2_0_6
vlib riviera/xbip_pipe_v3_0_6
vlib riviera/xbip_bram18k_v3_0_6
vlib riviera/mult_gen_v12_0_18
vlib riviera/xbip_dsp48_wrapper_v3_0_4
vlib riviera/xbip_dsp48_addsub_v3_0_6
vlib riviera/xbip_dsp48_multadd_v3_0_6
vlib riviera/dds_compiler_v6_0_22
vlib riviera/xil_defaultlib

vlog -work xilinx_vip  -incr -l axi_vip_v1_1_14 "+incdir+/usr/local/Vivado/2023.1/data/xilinx_vip/include" -l xilinx_vip -l xbip_utils_v3_0_10 -l axi_utils_v2_0_6 -l xbip_pipe_v3_0_6 -l xbip_bram18k_v3_0_6 -l mult_gen_v12_0_18 -l xbip_dsp48_wrapper_v3_0_4 -l xbip_dsp48_addsub_v3_0_6 -l xbip_dsp48_multadd_v3_0_6 -l dds_compiler_v6_0_22 -l xil_defaultlib \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/usr/local/Vivado/2023.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vcom -work xbip_utils_v3_0_10 -93  -incr \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_6 -93  -incr \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_6 -93  -incr \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_6 -93  -incr \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_18 -93  -incr \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93  -incr \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_6 -93  -incr \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_6 -93  -incr \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work dds_compiler_v6_0_22 -93  -incr \
"../../../ipstatic/hdl/dds_compiler_v6_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../../qick/firmware/projects/qick_tprocv2_4x2_standard/top/top.tmp/axis_signal_gen_v6_v1_0_project/axis_signal_gen_v6_v1_0_project.gen/sources_1/ip/dds_compiler_0/sim/dds_compiler_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

