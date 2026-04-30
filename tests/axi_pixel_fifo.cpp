#include "Vaxi_pixel_fifo.h"

#include "test_base.h"

int axi_send_data(Vaxi_pixel_fifo *top, uint16_t *data, int w, bool expect_read_complete, bool send_tlast);
int test_init_block(Vaxi_pixel_fifo *top, int cnt, int ppc);
void reset_block(Vaxi_pixel_fifo *top);

int main(int argc, char** argv) {
	int err = 0;
	VerilatedContext *contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vaxi_pixel_fifo *top = new Vaxi_pixel_fifo{contextp};

	const int w = 240, h = 20;
	const int pixels = w * h;
	const int cycles_per_pixel = 10;
	int i, iters, pixel;
	uint16_t *idata = (uint16_t*) malloc(pixels * sizeof(uint16_t));
	uint16_t *odata = (uint16_t*) calloc(pixels,  sizeof(uint16_t));
	for (i = 0; i < w * h; i++)
		idata[i] = 1 << (i % 16);//(uint16_t) ((i * (0xDEADBEEF + i)) ^ 0xCAFEBABE);

	// Hold the block in reset for a bit and make sure it starts up normally
	err = test_init_block(top, pixels, cycles_per_pixel);
	CHCK_FAIL_OR_PASS

	// Now that the IP is initialized, send some pixels
	printf("Attempting to send %d pixels over AXI bus... ", w);
	err = axi_send_data(top, idata, w, false, false);
	CHCK_FAIL_OR_PASS

	// Give a few dummy cycles to the IP block so the state machine does it's thing
	top->pixel_ready = 1;
	for(i = 0; i < 16; i++) {
		top->s_axis_clock = !top->s_axis_clock;
		top->eval();
	}

	// And read them back
	printf("Attempting to read back %d pixels over AXI bus... ", w);
	i = iters = pixel = 0;
	do {
		// Evaluate the IP block
		top->eval();
		if(top->s_axis_tready)
			break;

		// Generate the pixel clock signals
		if(top->core_clock_en && top->core_clock && i++ >= cycles_per_pixel) {
			iters = i = 0;
			top->pixel_sync = pixel == 0 ? 1 : 0;
			top->pixel_ready = !top->pixel_ready;
			if(top->pixel_ready) {
				if(top->pixel_data != idata[pixel]) {
					printf("FAIL - Pixel data for pixel %d was invalid (got = %04X, exp = %04X)!\n", pixel, top->pixel_data, idata[pixel]);
					FAIL_TEST
				}
				if(pixel++ >= pixels) pixel = 0;
			}
		}
		// Generate the AXI clock
		top->s_axis_clock = !top->s_axis_clock;
		// Make sure the loop exits
		if(iters++ > 10000) {
			printf("FAIL - Infinite loop detected!\n");
			FAIL_TEST
		}
	} while(1);
	puts("PASS");

gtfo:
	free(idata);
	free(odata);
	delete top;
	delete contextp;
	return err;
}

int axi_send_data(Vaxi_pixel_fifo *top, uint16_t *data, int w, bool expect_read_complete, bool send_tlast) {
	int x = 0, err = 0, iters = 0;
	// Bring the block out of reset and start it up
	top->s_axis_clock = 0;
	top->s_axis_aresetn = top->read_enable = 1;
	do {
 		top->eval();
		if(top->s_axis_clock && top->s_axis_tready) {
			top->s_axis_tdata = data[x++];
			bool last = x >= w;
			top->s_axis_tvalid = last ? 0 : 1;
			if(send_tlast) top->s_axis_tlast = last ? 1 : 0;
			if(x > w) {
				printf("FAIL - TREADY still asserted however the FIFO should be full!\n");
				err = 1; break;
			}
		}
		top->s_axis_clock = !top->s_axis_clock;

		if(iters++ > 1000) {
			printf("FAIL - Infinite loop detected!\n");
			err = 1; break;
		}

		if(top->read_complete) {
			if (x != w) {
				printf("FAIL - Incorrect number of bytes sent, sent %d bytes, expected to send %d bytes!\n", x, w);
				err = 1;
			}
			break;
		} else if(x == w) {
			if(expect_read_complete) {
				printf("FAIL - Sent %d / %d bytes yet fifo read complete was not set!\n", x, w);
				err = 1;
			}
			break;
		}
	} while(1);
	return err;
}
int test_init_block(Vaxi_pixel_fifo *top, int cnt, int ppc) {
	int iters = 0, pixel = 0, i = 0;
	printf("Holding the block in reset for a bit!\n");
	reset_block(top);
	printf("Waiting for block to initialize the display... ");
	top->s_axis_aresetn = 1;
	do {
		// Evaluate the IP block
		top->eval();
		// Generate the pixel clock signals
		if(top->core_clock_en && !top->core_clock && i++ >= ppc) {
			top->pixel_sync = (pixel % cnt) == 0 ? 1 : 0;
			top->pixel_ready = !top->pixel_ready;
			if(top->pixel_ready) pixel++;
			if(top->pixel_data != 0) {
				printf("FAIL - Pixel data was not zero during initialization!\n");
				return 1;
			}
			iters = i = 0;
		}
		// Generate the AXI clock
		top->s_axis_clock = !top->s_axis_clock;
		// Make sure the loop exits
		if(iters++ > 1000) {
			printf("FAIL - Taking too long to receive core clock\n");
			return 1;
		}
	} while(top->core_clock_en);

	if(pixel != cnt) {
		printf("FAIL - Received invlaid number of pixels: %d!\n", pixel);
		return 1;
	}

	return 0;
}
void reset_block(Vaxi_pixel_fifo *top) {
	top->s_axis_clock = top->s_axis_aresetn = 0;
	top->s_axis_tlast = top->s_axis_tvalid = 0;
	top->pixel_ready = 0;
	top->pixel_sync = 1;
	for(int i = 0; i < 1000; i++) {
		top->eval();
		top->s_axis_clock = !top->s_axis_clock;
	}
}
