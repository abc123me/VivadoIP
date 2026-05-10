#include "Vtft_ili9341_spi.h"

#include "util.h"

#include "test_base.h"

#define CHECK_DEFAULT_OUTPUTS(STR) top->eval();               \
	if(top->tft_sck) FAIL_MSG(STR " state of SCK was high!"); \
	if(top->tft_sdi) FAIL_MSG(STR " state of SDI was high!"); \
	if(top->tft_dc)  FAIL_MSG(STR " state of DC was high!");  \
	if(!top->tft_cs) FAIL_MSG(STR " state of CS was low!");   \
	if(!top->idle)   FAIL_MSG(STR " state of idle line was low!");

int main(int argc, char** argv) {
	int cnt, err = 0;
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vtft_ili9341_spi* top = new Vtft_ili9341_spi{contextp};

	printf("Testing values in initial state... ");
	top->clk = 0; top->data = 0; top->send = 0;
	CHECK_DEFAULT_OUTPUTS("Initial")
	puts("PASS");

	printf("Testing values in idle state... ");
	for(int i = 0; i < 8; i++) {
		top->clk = i & 1;
		CHECK_DEFAULT_OUTPUTS("Idle")
	}
	puts("PASS");

	printf("Testing sending all possible words... ");
	for(int dc = 0; dc < 2; dc++) {
		for(int val = 0; val < 256; val++) {
			// Latch in the data
			top->data = val | (dc << 8);
			top->send = 1;

			// Wait for chip select
			SAFE_WHILE(top->tft_cs, 4, {
				top->clk = !top->clk;
				top->eval();
			})

			// Start sending the data
			int bit = 128;
			top->clk = 0;
			top->eval();
			SAFE_WHILE(bit, 48, {
				top->clk = !top->clk;
				top->eval();
				if(top->tft_sck && !top->clk) {
					if(top->tft_sdi != ((val & bit) ? 1 : 0))
						FAIL_MSG("Data wasn't valid when sending %02X %s, bit %d", DATA_STR(top->data), bit)
					if(top->tft_dc != dc)
						FAIL_MSG("DC was invalid  when sending %02X %s, bit %d",   DATA_STR(top->data), bit)
					if(top->tft_cs)
						FAIL_MSG("CS was inactive when sending %02X %s, bit %d",   DATA_STR(top->data), bit)
					bit >>= 1;
				}
				top->send = 0;
			})

			// Make sure the block is in idle
			if(!top->idle)
				FAIL_MSG("Block wasn't in idle after sending %02X %s", DATA_STR(top->data))
			if(top->tft_cs)
				FAIL_MSG("Block CS went inactive earlier then expected")
		}
	}
	puts("PASS");
gtfo:
	delete top;
	delete contextp;
	return err;
}
