rtl_dir = ./rtl/
tb_dir	= ./tb/

rtl	= $(rtl_dir)rx_ethernet.v $(rtl_dir)rx_ipv4.v $(rtl_dir)rx_udp.v $(rtl_dir)wb_interface.v $(rtl_dir)RX_Vthernet_MAC.v $(rtl_dir)beh_sram_8x1024.v
tb 	= $(tb_dir)receive_tb.cpp

receive_test:
	verilator --cc -Wno-lint --trace --top-module top $(rtl_dir)top.v $(rtl) --exe $(tb)
	cd obj_dir; make -j -f Vtop.mk Vtop
	./obj_dir/Vtop

sram_test:
	verilator --cc -Wno-lint --trace --top-module beh_sram_8x1024 $(rtl_dir)beh_sram_8x1024.v $(rtl) --exe $(tb_dir)sram_tb.cpp
	cd obj_dir; make -j -f Vbeh_sram_8x1024.mk Vbeh_sram_8x1024
	./obj_dir/Vbeh_sram_8x1024

view: 
	gtkwave wave.vcd

clean:
	rm -r obj_dir
	rm wave.vcd
