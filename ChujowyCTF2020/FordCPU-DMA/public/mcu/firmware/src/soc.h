// SoC-specific defintions.

#ifndef __SOC_H
#define __SOC_H

#include <stdint.h>

// Device 0 ------ RAM
#define IRAM_START 0x00000000
#define IRAM_SIZE  0x00010000
#define IRAM_END   (IRAM_START + IRAM_SIZE)

// Device 1 ------ UART
#define UART_START    0xf0000000
#define UART_SIZE     0x00001000
#define UART_END      (UART_START + UART_SIZE)
#define UART_REG_DOUT (UART_START + 0x0000)

// Device 2 ------ LPT
#define LPT_START             0xf0010000
#define LPT_SIZE              0x00010000
#define LPT_END                   (LPT_START + LPT_SIZE)
#define LPT_REG_STATE             (LPT_START + 0x0000)
#define LPT_REG_RX_BUFFER_START   (LPT_START + 0x0004)
#define LPT_REG_RX_BUFFER_END     (LPT_START + 0x0008)
#define LPT_REG_RX_BUFFER_RX      (LPT_START + 0x000C)
#define LPT_REG_TX_BUFFER_START   (LPT_START + 0x0010)
#define LPT_REG_TX_BUFFER_END     (LPT_START + 0x0014)

#define IRQ_LPT_RX_DONE 3
#define IRQ_LPT_RX_FULL 2
#define IRQ_LPT_TX_DONE 1

// Device 3 ------ Flag Device TM
#define FLAG_DEV_START             0xf0100000
#define FLAG_DEV_SIZE              0x00010000
#define FLAG_DEV_END               (FLAG_DEV_START + FLAG_DEV_SIZE)
#define FLAG_DEV_PIN               (FLAG_DEV_START + 0x0000)
#define FLAG_DEV_CHECK_START       (FLAG_DEV_START + 0x0010)
#define FLAG_DEV_DEVICE_STATUS     (FLAG_DEV_START + 0x0014)
#define FLAG_DEV_PIN_STATUS        (FLAG_DEV_START + 0x0018)
#define FLAG_DEV_FLAG_START        (FLAG_DEV_START + 0x0020)

#define REG32(addr) (*(uint32_t *)addr)

#endif
