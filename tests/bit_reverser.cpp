#include "Vbit_reverser.h"

#include "test_base.h"

int main(int argc, char** argv) {
	int err = 0;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vbit_reverser* top = new Vbit_reverser{contextp};

	for (int w = 0; w < 2; w++) {
		for (int b = 0; b < 8; b++) {
			printf("Testing if bit %d in word %d is mapped to bit %d in word %d... ", b + 1, w, 8 - b, w);
			int inp_val = (1 << b)   << (w * 8);
			int exp_val = (128 >> b) << (w * 8);

			top->inp = inp_val;
			top->eval();
			if (top->outp != exp_val) {
				printf("FAIL, got = %08X (exp = %08X)!\n", top->outp, exp_val);
				FAIL_TEST
			} else puts("PASS");
		}
	}

gtfo:
	delete top;
	delete contextp;
	return err;
}
