// HardHardFlag simulator.

#include <thread>
#include <cstdio>
#include <unistd.h>
#include <fcntl.h>
#include <sys/poll.h>

#include "Vtop.h"
#include "verilated_vcd_c.h"

const bool enable_vcd = false;

Vtop *top;
VerilatedVcdC* tfp;

unsigned long int current_cycle = 0;
int running = 1;

int to_uc[2];
int from_uc[2];

const int divider = 100000000 / 1000000;
void uart_read() {
    static unsigned long int start_cycle = 0;
    static uint8_t data = 0;

    if (start_cycle == 0) {
        if (top->uart_tx == 0) {
            start_cycle = current_cycle + divider / 2;
        }
    } else {
        if (start_cycle > current_cycle)
            return;
        long int bit = (current_cycle - start_cycle) / divider;
        long int rest = (current_cycle - start_cycle) % divider;
        if (rest == 0) {
            if (bit > 0 && bit < 9) {
                if (top->uart_tx) {
                    data |= (1 << (bit-1));
                }
            }
            if (bit >= 9) {
                fprintf(stdout, "%c", data);
                fflush(stdout);
                start_cycle = 0;
                data = 0;
            }
        }
    }
}

void c(int num = 1) {
    for (int i = 0; i < num; i++) {
        top->clk = 1;
        top->eval();
        if (enable_vcd) {
            tfp->dump(current_cycle*2);
        }
        top->clk = 0;
        top->eval();
        if (enable_vcd) {
            tfp->dump(current_cycle*2+1);
        }

        current_cycle++;
        uart_read();
    }
}

void mcu_loop() {
    char buff[4];

    // Power-on-reset.
    top->lpt_in_valid = 0;
    top->lpt_out_ready = 0;

    top->resetn = 1;
    c(10);
    top->resetn = 0;
    c(10);

    // Run.
    top->resetn = 1;
    top->lpt_out_ready = 1;
    while(running) {
        c();
        if (top->trap) {
            // Reset on CPU failure.
            fprintf(stdout, "resetting...\n");
            top->resetn = 0;
            c(10);
            top->resetn = 1;
        }

        if (top->lpt_out_valid) {
          write(from_uc[1], &top->lpt_out_data, 4);
        }

        if (top->lpt_in_ready && top->lpt_in_valid) {
            top->lpt_in_valid = 0;
            continue;
        }

        if (top->lpt_in_ready) {
            // MCU is able to accept more data
            // Try reading data from user
            if(read(to_uc[0], buff, 4) < 0) {
              if(errno == EAGAIN)
                continue;
            }

            // Send data to device
            memcpy(&top->lpt_in_data, buff, 4);
            top->lpt_in_valid = 1;
        }
    }
}

void io_loop() {
  struct pollfd pfds[2];
  char buff[4];
  int in = 0;

  pfds[0].fd = 0; // stdin
  pfds[0].events = POLLIN;

  pfds[1].fd = from_uc[0];
  pfds[1].events = POLLIN;

  while(running) {
    poll(pfds, 2, -1);
    if(pfds[0].revents & POLLIN) {
      // Send STDIN to mcu
      in += read(0, buff + in, 4 - in);
      if (in == 4) {
        write(to_uc[1], buff, 4);
        in = 0;
      }
    }

    if(pfds[1].revents & POLLIN) {
      // Send mcu output to user
      read(from_uc[0], buff, 4);
      write(1, buff, 4);
    }
    
    if ((pfds[0].revents & POLLERR) || (pfds[0].revents & POLLHUP)) {
        running = 0;
    }
    
    if ((pfds[1].revents & POLLERR) || (pfds[1].revents & POLLHUP)) {
        running = 0;
    }
  }
}

int main(int argc, char **argv) {
  // Disable buffering
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stdin, NULL, _IONBF, 0);

  // Setup non blocking IO on STDIN
  if(fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK)) {
    perror("fcntl");
    exit(EXIT_FAILURE);
  }

  Verilated::commandArgs(argc, argv);

  // Prepare communication pipes
  if(pipe2(from_uc, O_NONBLOCK)) {
    perror("pipe");
    exit(EXIT_FAILURE);
  }

  if(pipe2(to_uc, O_NONBLOCK)) {
    perror("pipe");
    exit(EXIT_FAILURE);
  }

  if (enable_vcd) {
      Verilated::traceEverOn(true);
  }
  top = new Vtop;
  if (enable_vcd) {
      char vcdName[64];
      sprintf(vcdName, "/tmp/out%04d.vcd", getpid());
      tfp = new VerilatedVcdC;
      top->trace(tfp, 99);
      tfp->open(vcdName);
  }

  // Start the simulation
  std::thread mcu(mcu_loop);
  std::thread io(io_loop);
  mcu.join();
  io.join();

  if (enable_vcd) {
      delete tfp;
  }
  delete top;
}
