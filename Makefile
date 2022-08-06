rtl_dir = ./rtl/
tb_dir	= ./tb/

rtl	= $(rtl_dir)rx_ethernet.v $(rtl_dir)rx_ipv4.v $(rtl_dir)rx_udp.v $(rtl_dir)wb_interface.v
reram	= $(PDK_ROOT)sky130B/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_8x1024_8.v
tb 	= $(tb_dir)receive_tb.cpp

receive_test:
ifndef PDK_ROOT
	@echo "please set PDK_ROOT"
	exit 1
endif
	verilator --cc -Wno-lint --trace --top-module top $(rtl_dir)top.v $(rtl) $(reram) --exe $(tb)
	cd obj_dir; make -j -f Vtop.mk Vtop

run:
	./obj_dir/Vtop

view: 
	gtkwave wave.vcd

clean:
	rm -r obj_dir
	rm wave.vcd
