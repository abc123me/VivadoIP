#include "Vtft_ili9341_init.h"

#include "test_base.h"

#include "init.h"
#include "util.h"

int main(int argc, char** argv) {
	char err_str1[32], err_str2[32];
	int err = 0, i, init_val, init_pos;
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
			FAIL_MSG("Block init data in reset state was incorrect")
	}
	puts("PASS");

	top->clock_enable = 0;
	top->resetn = 1;
	printf("Testing how the block reacts to having clock w/o clock enable... ");
	for(i = 0; i < 7; i++) {
		top->eval();
		top->clock = !top->clock;
		if(top->data != INIT_SEQ[0])
			FAIL_MSG("Block init data in reset state was incorrect")
	}
	puts("PASS");

	printf("Testing if the init sequence is valid... ");
	top->clock = 0;
	top->clock_enable = 1;
	init_pos = 0;
	for(i = 0; i < INIT_SEQ_LEN * 3; i++) {
		if(top->clock) init_pos++;
		top->eval();
		top->clock = !top->clock;
		init_val = INIT_SEQ[init_pos];
		if(top->data != init_val)
			FAIL_MSG("Init data at %d was incorrect, got 0x%02X %s, exp 0x%02X %s",
					init_pos, DATA_STR(top->data), DATA_STR(init_val));
		if(top->done)
			break;
	}
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
