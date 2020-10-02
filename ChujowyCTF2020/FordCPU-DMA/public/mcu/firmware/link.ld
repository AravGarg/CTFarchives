SECTIONS {
	.text : {
        _ftext = .;
        *(.text);
        _etext = .;
	}

    .bss : {
        . = ALIGN(4);
        _fbss = .;
        *(.bss);
        _ebss = .;
    }
}
