def put_on_stack(string):
    """
    Generate the bytecode required to put a single string
    onto the stack.
    """
    op = b""
    for n, i in enumerate(string):
        # LOAD_GLOBAL 0 (chr)
        op += b"t\x00"

        # LOAD_CONST n
        op += b"d" + bytes([ord(i)])

        # CALL_FUNCTION 1
        op += b"\x83\x01"

        if n != 0:
            # BINARY_ADD
            op += b"\x17\x00"
    return op

def execute_bytecode(code):
    """
    Executes the provided bytecode. Handy for getting the
    top item off the stack.
    """
    from types import CodeType
    import builtins

    # This should be large enough for most things
    stacksize = 1024

    # Load in enough for put_on_stack to work.
    # NOTE: This function is unable to call "import" or similar
    #       dangerous things due to co_names acting as a whitelist.
    #     (Python loads names from a constants array, so it can"t
    #      load something that"s not there!)
    consts = (*range(256), )
    names = ("chr", "ord", "globals", "locals", "getattr", "setattr")

    # Tag on a trailing RETURN call just incase.
    code += b"S\x00"
    # Construt the code object
    inject = CodeType(
        0,  # For python 3.8
        0, 0, 0, stacksize, 2, code, consts,
        names, (), "", "", 0, b"", (), ()
    )

    # Create a copy of globals() and load in builtins. builtins aren"t
    # normally included in global scope.
    globs = dict(globals())
    globs.update({i: getattr(builtins, i) for i in dir(builtins)})

    # Go go go!
    return eval(inject, globs)

def smart_input():
    """
    This function aims to make python 3's input smart:tm:
    It checks if you're piping or redirecting, and switches to reading
    from stdin directly.
    """
    import os, sys, stat
    mode = os.fstat(0).st_mode

    if stat.S_ISREG(mode) or stat.S_ISFIFO(mode):
        return sys.stdin.buffer.read()
    return input().encode()

print("Hello!")
print("What's your name?")
name = smart_input()
name = put_on_stack(name[:32].decode()) + name[32:]
print(f"Hello {execute_bytecode(name)}!")
print("It's nice to meet you!")
