rtl_dir = ./rtl/
tb_dir	= ./tb/

rtl	= $(rtl_dir)rx_ethernet.v $(rtl_dir)rx_ipv4.v $(rtl_dir)rx_udp.v
tb 	= $(tb_dir)receive_tb.cpp

receive_test:
	verilator --cc -Wno-lint --trace --top-module top $(rtl_dir)top.v $(rtl) --exe $(tb)
	cd obj_dir; make -j -f Vtop.mk Vtop

run:
	./obj_dir/Vtop

clean:
	rm -r obj_dir
	rm wave.vcd
