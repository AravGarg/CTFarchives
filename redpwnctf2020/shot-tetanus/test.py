from pwn import *
import base64

string=(base64.b64decode("UK4cRIQoC6CqgCXpQeQIyU6V0PL6UZ+P/XEROuEd2XqqG77e6Op7ittY2dy0oUppbiLf1hBSSiyq+aWAViCIoSXmKsp4d3I3zJie3w8G35Q="))
for char in string:
	print(ord(char)), 
