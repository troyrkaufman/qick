transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_vip_2  -L xilinx_vip -L axi_infrastructure_v1_1_0 -L xil_defaultlib -L axi_vip_v1_1_14 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_vip_2 xil_defaultlib.glbl

do {axi_vip_2.udo}

run 1000ns

endsim

quit -force
