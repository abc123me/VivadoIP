#include "Vtft_ili9341_init.h"

#include "test_base.h"

#include "init.h"
#include "util.h"

int main(int argc, char** argv) {
	char err_str1[32], err_str2[32];
	int err = 0, i, init_pos;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtft_ili9341_init* top = new Vtft_ili9341_init{contextp};

	top->clock = 0;
	top->clock_enable = 0;
	top->resetn = 0;
	printf("Testing how the block reacts to reset being held w/o clock enable... ");
	for(i = 0; i < 7; i++) {
		top->eval();
		top->clock = !top->clock;
		if(top->data != INIT_SEQ[0])
			FAIL_MSG("Block init data in reset state was incorrect, got 0x%02X, exp 0x%02X", top->data, INIT_SEQ[0])
	}
	puts("PASS");

	top->clock_enable = 0;
	top->resetn = 1;
	printf("Testing how the block reacts to having clock w/o clock enable... ");
	for(i = 0; i < 7; i++) {
		top->eval();
		top->clock = !top->clock;
		if(top->data != INIT_SEQ[0])
			FAIL_MSG("Block init data in reset state was incorrect, got 0x%02X, exp 0x%02X", top->data, INIT_SEQ[0])
	}
	puts("PASS");

	printf("Testing if the init sequence is valid... ");
	top->clock = 0;
	top->clock_enable = 1;
	init_pos = 0;
	for(i = 0; i < INIT_SEQ_LEN * 3; i++) {
		top->eval();
		top->clock = !top->clock;

		if(top->done) {
			printf("Init sequence completed!\n");
			goto top_done;
		}

		if(init_pos >= INIT_SEQ_LEN)
			FAIL_MSG("Init position exceeded INIT_SEQ_LEN");

		printf("Init sequence @ %d: 0x%03X\n", init_pos, top->data);
		if(top->data != INIT_SEQ[init_pos])
			FAIL_MSG("Init data at %d was incorrect, got 0x%02X %s, exp 0x%02X %s",
					init_pos, DATA_STR(top->data), DATA_STR(INIT_SEQ[init_pos]));

		if(top->clock)
			init_pos++;
	}
	FAIL_MSG("Init sequence never asserted completion!");
top_done:
	if(i != INIT_SEQ_LEN * 2 - 1)
		FAIL_MSG("Invalid init sequence length: %d", i);
	if(init_pos != INIT_SEQ_LEN)
		FAIL_MSG("Invalid init sequence position: %d", init_pos);
	if(!top->done)
		FAIL_MSG("top->done was not asserted?!");
	puts("PASS");

gtfo:
	delete top;
	delete contextp;
	return err;
}
