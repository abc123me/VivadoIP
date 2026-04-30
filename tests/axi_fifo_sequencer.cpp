#include "Vaxi_fifo_sequencer.h"

#include "test_base.h"

#define CHECK_SIGNAL(line, name) \
	tmp = top->m##line##_axis_##name; \
	if(tmp != name) { \
		printf("FAIL - Signal " #name " for line " #line " wasn't propogated (got=%d, exp=%d)!\n", tmp, name); \
		FAIL_TEST \
	}

#define CHECK_AXI_SIGNALS(line) \
	CHECK_SIGNAL(line, tdata)   \
	CHECK_SIGNAL(line, tlast)   \
	CHECK_SIGNAL(line, tvalid)

int main(int argc, char** argv) {
	int err = 0, tmp = 0, i, j;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vaxi_fifo_sequencer* top = new Vaxi_fifo_sequencer{contextp};

	top->axis_clock = 0;
	top->axis_aresetn = 0;
	top->read_completes = 0;
	top->eval();

	printf("Testing TLAST, TDATA, and TVALID are all routed through IP... ");
	int vals[] = { 0xFFFF, 0x8000, 0x5555, 0xA5A5, 0x5A5A, 0xAAAA, 0x0001, 0x0000, -1 };
	for (int i = 0; vals[i] > 0; i++) {
		int tdata  = vals[i];
		int tlast  = (vals[i] & 1) ? 1 : 0;
		int tvalid = (vals[i] & 1) ? 0 : 1;
		// These signals should all be directly wired
		top->s_axis_tdata = tdata;
		top->s_axis_tlast = tlast;
		top->s_axis_tvalid = tvalid;
		top->eval();
		CHECK_AXI_SIGNALS(00)
		CHECK_AXI_SIGNALS(01)
		CHECK_AXI_SIGNALS(02)
		CHECK_AXI_SIGNALS(03)
		CHECK_AXI_SIGNALS(04)
		CHECK_AXI_SIGNALS(05)
		CHECK_AXI_SIGNALS(06)
		CHECK_AXI_SIGNALS(07)
		CHECK_AXI_SIGNALS(08)
		CHECK_AXI_SIGNALS(09)
		CHECK_AXI_SIGNALS(10)
		CHECK_AXI_SIGNALS(11)
		CHECK_AXI_SIGNALS(12)
		CHECK_AXI_SIGNALS(13)
		CHECK_AXI_SIGNALS(14)
		CHECK_AXI_SIGNALS(15)
	}
	puts("PASS");

	top->axis_aresetn = 0;
	for(i = 0; i < 10; i++) {
		top->axis_clock = !top->axis_clock;
		top->eval();
	}

	printf("Testing all TREADYs and read enables are zero when in reset... ");
	if(top->s_axis_tready) {
		puts("FAIL - TREADY was high despite being help in reset for multiple clock cycles!");
		FAIL_TEST
	}
	if(top->read_enables) {
		puts("FAIL - Read enables were high despite being help in reset for multiple clock cycles!");
		FAIL_TEST
	}
	puts("PASS");

	top->axis_aresetn = 1;
	top->m00_axis_tready = 1;
	for(i = 0; i < 2; i++) {
		top->axis_clock = !top->axis_clock;
		top->eval();
	}

	top->read_completes = 0;
	for (i = 0; i < 16; i++) {
		int k = i % 4;
		volatile auto *tready = &top->m00_axis_tready;
		switch(k) {
			case 0: tready = &top->m00_axis_tready; break;
			case 1: tready = &top->m01_axis_tready; break;
			case 2: tready = &top->m02_axis_tready; break;
			case 3: tready = &top->m03_axis_tready; break;
		}

		*tready = 1;
		for(j = 0; j < 4; j++) {
			top->axis_clock = !top->axis_clock;
			top->eval();
		}

		printf("Testing TREADY line number %d... ", k);
		if(!top->s_axis_tready) {
			printf("FAIL - TREADY was not high despite master TREADY %d being set high!\n", k);
			FAIL_TEST
		}
		if(top->read_enables & (1 << k) == 0) {
			printf("FAIL - Read enable wasn't asserted despite TREADY being asserted, got=%04X!\n", top->read_enables);
			FAIL_TEST
		}
		puts("PASS");
		*tready = 0;

		printf("Testing read_complete moves to next TREADY line... ", k);
		top->read_completes |= 1 << k;
		for(j = 0; j < 4; j++) {
			top->axis_clock = !top->axis_clock;
			top->eval();
		}
		if(top->read_enables & (1 << k)) {
			printf("FAIL - Read enable wasn't asserted despite TREADY being asserted, got=%04X!\n", top->read_enables);
			FAIL_TEST
		}
		puts("PASS");
		top->read_completes &= ~(1 << k);
	}

gtfo:
	delete top;
	delete contextp;
	return err;
}
