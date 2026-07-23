#include "Vdiscrete_clock_converter.h"

#include "test_base.h"


int main(int argc, char** argv) {
	int err = 0;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vdiscrete_clock_converter* top = new Vdiscrete_clock_converter{contextp};

	printf("Testing discrete_clock_converter propagates outputs... ");
	top->inp_resetn = 1;
	top->inp_clock = 0;
	top->out_resetn = 1;
	top->out_clock = 0;
	top->eval();
	top->data_inp = 0xBABE;
	top->inp_clock = 1;
	top->eval();
	top->out_clock = 1;
	top->eval();
	if (top->data_out != 0xBABE) {
		printf("FAIL - Data did not propogate through discrete clock converter!\n");
		FAIL_TEST
	} else puts("PASS");

gtfo:
	delete top;
	delete contextp;
	return err;
}
