#include "Voneshot.h"

#include "test_base.h"

int main(int argc, char** argv) {
	int err = 0;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Voneshot* top = new Voneshot{contextp};

	printf("Testing oneshot default state... ");
	top->trigger = 0;
	top->reset = 0;
	top->eval();
	if (top->outp) {
		printf("FAIL - Oneshot was active when trigger/reset were low!\n");
		FAIL_TEST
	} else puts("PASS");

	printf("Testing oneshot trigger state... ");
	top->trigger = 1;
	top->reset = 0;
	top->eval();
	top->trigger = 0;
	if (!top->outp) {
		printf("FAIL - Oneshot was not active when trigger was high!\n");
		FAIL_TEST
	} else puts("PASS");

	printf("Testing oneshot trigger state after 10 evals... ");
	for(int i = 0; i < 10; i++) top->eval();
	if (!top->outp) {
		printf("FAIL - Oneshot was not active when trigger was high!\n");
		FAIL_TEST
	} else puts("PASS");

	printf("Testing oneshot reset state... ");
	top->trigger = 0;
	top->reset = 1;
	top->eval();
	top->reset = 0;
	if (top->outp) {
		printf("FAIL - Oneshot was active when reset was high!\n");
		FAIL_TEST
	} else puts("PASS");

	printf("Testing oneshot reset state after 10 evals... ");
	for(int i = 0; i < 10; i++) top->eval();
	if (top->outp) {
		printf("FAIL - Oneshot was active when reset was high!\n");
		FAIL_TEST
	} else puts("PASS");

gtfo:
	delete top;
	delete contextp;
	return err;
}
