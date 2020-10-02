// Board Support Package for newlib

#include <sys/stat.h>
#include <sys/errno.h>

#include "soc.h"

// From linker/start.S
extern char _heap_start;
extern char _heap_end;

// Serve heap from static space.

static char *heap_end;
caddr_t _sbrk(int incr) {
    char *prev_heap_end;
    if (heap_end == 0) {
        heap_end = &_heap_start;
    }
    prev_heap_end = heap_end;

    if (heap_end + incr > &_heap_end) {
        return (caddr_t)0;
    }
    _heap_end += incr;
    return (caddr_t) prev_heap_end;
}

// Write to UART.
int _write(int file, char *ptr, int len) {
    for (int i = 0; i < len; i++) {
        REG32(UART_REG_DOUT) = *ptr++;
    }
    return len;
}

// Stubs.

int _isatty(int file) { return 1; }

int _lseek(int file, int ptr, int dir) { return 0; }

int _open(const char *name, int flags, int mode) { return -1; }

int _read(int file, char *ptr, int len) { return EIO; }

int _close(int file) { return -1; }

int _fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}
