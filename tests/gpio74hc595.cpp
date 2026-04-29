#include "Vgpio74hc595.h"

#include "verilated.h"

#include "stdint.h"
#include "stdio.h"

#define SREG_ERR_OVERFLOW 1

struct shift_reg_t {
	uint32_t istate, ostate;
	uint8_t pos, bits;
	uint8_t errors;
};

void sim_chip(shift_reg_t *reg, Vgpio74hc595 *top);
void print_chip(shift_reg_t *reg);
void init_chip(shift_reg_t *reg, int cnt);

int test_shift_val_out(Vgpio74hc595 *top, int wr_val, int rb_val, shift_reg_t *reg) {
	int err = 0;

	printf("Running shift out test with value %d...", wr_val);

	while(!top->driver_latch) {
		top->clock = !top->clock;
		top->eval();
		sim_chip(reg, top);
	}

	if(reg->ostate == reg->istate) {
		puts("PASS");
		while(top->driver_latch) {
			top->clock = !top->clock;
			top->eval();
			sim_chip(reg, top);
		}
	} else {
		printf("FAIL (got = %08X, exp = %08X)\n", reg->ostate, rb_val);
		print_chip(reg);
		err = 1;
	}

gtfo:
	return err;
}

int main(int argc, char** argv) {
	VerilatedContext *contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vgpio74hc595 *top = new Vgpio74hc595{contextp};
	shift_reg_t *reg = (shift_reg_t*) alloca(sizeof(shift_reg_t));
	int err = 0;

	init_chip(reg, 1);

	top->clock = 1;
	top->resetn = 1;
	top->eval();
	sim_chip(reg, top);

	err = test_shift_val_out(top, 0x69, 0x69, reg);
	err = test_shift_val_out(top, 0xAA, 0xAA, reg);
	err = test_shift_val_out(top, 0xA5, 0xA5, reg);
	err = test_shift_val_out(top, 0x55, 0x55, reg);
	err = test_shift_val_out(top, 0x5A, 0x5A, reg);
	err = test_shift_val_out(top, 0x80, 0x80, reg);
	err = test_shift_val_out(top, 0x01, 0x01, reg);

	top->resetn = 0;
	err = test_shift_val_out(top, 0x55, 0x00, reg);
	err = test_shift_val_out(top, 0xAA, 0x00, reg);

gtfo:
	delete top;
	delete contextp;
	return err;
}

void sim_chip(shift_reg_t *reg, Vgpio74hc595 *top) {
	if (top->driver_clock) {
		reg->istate = (reg->istate & ~(1 << reg->pos)) | (top->driver_data << reg->pos);
		reg->pos++;
		if(reg->pos >= reg->bits) {
			reg->pos = 0;
			reg->errors |= SREG_ERR_OVERFLOW;
		}
	}
	if(!top->driver_resetn) {
		reg->istate = 0;
	}
	if(top->driver_latch) {
		reg->ostate = reg->istate;
	}
}

void init_chip(shift_reg_t *reg, int cnt) {
	memset(reg, 1, sizeof(shift_reg_t));
	reg->bits = cnt * 8;
}
void print_chip(shift_reg_t *reg) {
	puts("Chip state: ");
	printf("Internal state: 0x%08X\n",  reg->istate);
	printf("Output state:   0x%08X\n",  reg->ostate);
	printf("Position:       %u / %u\n", reg->pos, reg->bits - 1);
	printf("Error register: 0x%08X\n",  reg->errors);
}
