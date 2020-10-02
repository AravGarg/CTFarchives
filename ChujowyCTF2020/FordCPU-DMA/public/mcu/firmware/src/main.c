#include <stdio.h>
#include <string.h>

#include "soc.h"
#include "irq.h"

volatile uint32_t cmd[257] __attribute__((aligned(4)));
volatile int tx_done = 1;
volatile char* response = NULL;

void fast_send(char* str, int size) {
    while (!tx_done);
    tx_done = 0;
    REG32(LPT_REG_TX_BUFFER_START) = (uint32_t)str;
    REG32(LPT_REG_TX_BUFFER_END) = (uint32_t)str + size;
}

char buff[4] __attribute__((aligned(4)));
void fast_puts(char* str) {
    int len = strlen(str);
    int extra = len & 3;
    int first = len-extra;
    if (first > 0)
        fast_send(str, first);

    if(!extra)
        return;

    memset(buff, 0, 4);
    for(int i = 0; i<extra; i++)
        buff[i] = str[first + i];

    fast_send(buff, 4);
}

void main() {
    // Make sure that the command buffer is null terminated
    cmd[256] = 0;

    // Print welcome message via UART
    printf("Booting the HardHardFlag MCU :D\n");
    printf("This MCU is running a picorv32 core which I've got from github\n");
    printf("It must be 100 percent secure.\n");
    printf("I added some peripherals to it via the AXI4 bus xD\n");
    printf("I hated the slow transfer rates of UART.\n");
    printf("So I've added a parallel port with DMA to it to make it faster xD\n");
    printf("TERMINATING SLOW UART - TIME FOR 1337 DMA xD\n");

    // Wait some time for the UART to be send to the user
    for(int i = 0; i<20000; i++);

    // Enable TX for parallel port
    REG32(LPT_REG_STATE) = 2;

    // Enable interrupts
    _irq_maskirq(0);

    fast_puts("Now as I'm using DMA my messages should appear instantly.\n");
    fast_puts("TEEEEEEEEEEEEEEEEEEEEEEEEEEST\n");
    fast_puts("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n");

    fast_puts("Now as you can see the output appears really fast on the screen\n");
    fast_puts("xD xD XD Can you PWN my DMA controller? xD xD XD\n");

    // Enable RX & TX for parallel port
    REG32(LPT_REG_RX_BUFFER_START) = cmd;
    REG32(LPT_REG_RX_BUFFER_END) = cmd + 256;
    REG32(LPT_REG_STATE) = 2 | 1;

    for(;;) {
        while (!response);
        char* copy = response;
        response = 0;
        fast_puts(copy);
    }
}

typedef void (*irq_handler)(void);

static void irq_lpt_tx_done(void) {
  tx_done = 1;
}

static void irq_lpt_rx_full(void) {
    response = "Command too long\n";

    // Send ack that the data was processed
    REG32(LPT_REG_RX_BUFFER_RX) = 1;
}

static int safe_cmd_compare(char* arg, const char* cmd) {
    int len1 = strlen(cmd);
    int len2 = REG32(LPT_REG_RX_BUFFER_RX)-(uint32_t)arg;
    if(len1 != len2)
        return 1;
    return memcmp(arg, cmd, len1);
}

volatile int eula_accepted = 0;
volatile int flag_mode = 0;
static void process_command(char* arg) {
    if(!safe_cmd_compare(arg, "inf\n")) {
        response = "This leet mcu is powered by the new RISCV architecture :D\n";
        goto exit;
    }
    if(!safe_cmd_compare(arg, "eula")) {
        response = "[END USER LICENCE AGREEMENT] INSERT SOME LONG TEXT HERE\nIf you accept the EULA then send ack\n";
        goto exit;
    }
    if(!safe_cmd_compare(arg, "ack\n")) {
        response = "OK\n";
        eula_accepted = 1;
        goto exit;
    }
    if(!safe_cmd_compare(arg, "cmp\n")) {
        if(!eula_accepted) {
            response = "You must accept the EULA\n";
            goto exit;
        } else {
            response = "Now you have 3 tries to guess the flag\n";
            flag_mode = 1;
            goto exit;
        }
    }

    response = "Invalid command\n";
exit:
  return;
}

const char FLAG[] = "FAKE_FLAG";
const int FLAG_SIZE = sizeof(FLAG);
volatile int tries = 0;
static void check_flag(char *arg) {
    char c = 0;
    for(int i = 0; i<FLAG_SIZE; i++) {
        c |= (FLAG[i] ^ arg[i]);
    }

    if (!c) {
        response = FLAG;
        tries = 0;
        return;
    }

    if(tries == 2) {
        // Send trap so the simulator reboots the CPU
        tries = 0;
        flag_mode = 0;
        eula_accepted = 0;
        __asm__ __volatile__ ("ebreak");
    }

    response = "INVALID FLAG\n";
    tries += 1;
}

static void irq_lpt_rx_done(void) {
    if(!flag_mode)
        process_command(cmd);
    else
        check_flag(cmd);

    // Send ack that the data was processed
    REG32(LPT_REG_RX_BUFFER_RX) = 1;
}

static irq_handler irq_handlers[32] = {
    [IRQ_LPT_TX_DONE] = irq_lpt_tx_done,
    [IRQ_LPT_RX_FULL] = irq_lpt_rx_full,
    [IRQ_LPT_RX_DONE] = irq_lpt_rx_done
};

void isr(uint32_t pending) {
    for (int irqn = 0; irqn < 32; irqn++) {
        if (pending & (1 << irqn)) {
            if (irq_handlers[irqn] != 0) {
                irq_handlers[irqn]();
            } else {
                printf("ERR: IRQ %d undhandled!\n", irqn);
            }
        }
    }
}
