#include "Vtft_ili9341_init.h"

#include "test_base.h"

#define INIT_SEQ_ENTRY(bit, val) ((bit << 8) | val)
#define INIT_SEQ_LEN 52

#define DATA_STR(val) (val & 0xFF), (val & 0x100 ? "w/ DC" : "w/o DC")

const int INIT_SEQ[INIT_SEQ_LEN] = {
	// Turn off Display
	INIT_SEQ_ENTRY(0, 0x28),
	// Init (??)
	INIT_SEQ_ENTRY(0, 0xCF), INIT_SEQ_ENTRY(1, 0x00), INIT_SEQ_ENTRY(1, 0x83), INIT_SEQ_ENTRY(1, 0x30),
	INIT_SEQ_ENTRY(0, 0xED), INIT_SEQ_ENTRY(1, 0x64), INIT_SEQ_ENTRY(1, 0x03), INIT_SEQ_ENTRY(1, 0x12), INIT_SEQ_ENTRY(1, 0x81),
	INIT_SEQ_ENTRY(0, 0xE8), INIT_SEQ_ENTRY(1, 0x85), INIT_SEQ_ENTRY(1, 0x01), INIT_SEQ_ENTRY(1, 0x79),
	INIT_SEQ_ENTRY(0, 0xCB), INIT_SEQ_ENTRY(1, 0x39), INIT_SEQ_ENTRY(1, 0x2C), INIT_SEQ_ENTRY(1, 0x00), INIT_SEQ_ENTRY(1, 0x34), INIT_SEQ_ENTRY(1, 0x02),
	INIT_SEQ_ENTRY(0, 0xF7), INIT_SEQ_ENTRY(1, 0x20),
	INIT_SEQ_ENTRY(0, 0xEA), INIT_SEQ_ENTRY(1, 0x00), INIT_SEQ_ENTRY(1, 0x00),
	// Power Control
	INIT_SEQ_ENTRY(0, 0xC0), INIT_SEQ_ENTRY(1, 0x26),
	INIT_SEQ_ENTRY(0, 0xC1), INIT_SEQ_ENTRY(1, 0x11),
	// VCOM
	INIT_SEQ_ENTRY(0, 0xC5), INIT_SEQ_ENTRY(1, 0x35), INIT_SEQ_ENTRY(1, 0x3E),
	INIT_SEQ_ENTRY(0, 0xC7), INIT_SEQ_ENTRY(1, 0xBE),
	// Memory Access Control
	INIT_SEQ_ENTRY(0, 0x3A), INIT_SEQ_ENTRY(1, 0x55),
	// Frame Rate
	INIT_SEQ_ENTRY(0, 0xB1), INIT_SEQ_ENTRY(1, 0x00), INIT_SEQ_ENTRY(1, 0x1B),
	// Gamma
	INIT_SEQ_ENTRY(0, 0x26), INIT_SEQ_ENTRY(1, 0x01),
	// Brightness
	INIT_SEQ_ENTRY(0, 0x51), INIT_SEQ_ENTRY(1, 0xFF),
	// Display
	INIT_SEQ_ENTRY(0, 0xB7), INIT_SEQ_ENTRY(1, 0x07),
	INIT_SEQ_ENTRY(0, 0xB6), INIT_SEQ_ENTRY(1, 0x0A), INIT_SEQ_ENTRY(1, 0x82), INIT_SEQ_ENTRY(1, 0x27), INIT_SEQ_ENTRY(1, 0x00),
	INIT_SEQ_ENTRY(0, 0x29), // Enable Display
	INIT_SEQ_ENTRY(0, 0x2C), // Start Memory-Write
};

int main(int argc, char** argv) {
	char err_str1[32], err_str2[32];
	int err = 0, i, init_val, init_pos;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtft_ili9341_init* top = new Vtft_ili9341_init{contextp};

	top->reset = 1;
	top->clock = 0;
	printf("Testing how the block reacts to reset... ");
	for(i = 0; i < 3; i++) {
		top->eval();
		top->clock = !top->clock;
		if(top->data != INIT_SEQ[0])
			FAIL_MSG("Block init data in reset state was incorrect")
	}
	puts("PASS");

	printf("Testing if the init sequence is valid... ");
	top->reset = 0;
	top->clock = 0;
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
