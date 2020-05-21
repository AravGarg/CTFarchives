#!/usr/bin/env python3

import gensafeprime
import contextlib
import textwrap
import hashlib
import fuckpy3 #pylint:disable=unused-import
import random
import numpy as np
import ast
import os
import re

USER=input("Username: ")

assert USER.lower() != "zardus", "That's me!"
assert USER.lower() != "malina", "Nope!"
assert USER.lower() != "ooo","No way!"
assert re.match(r"^\w+$",USER), "Invalid username format!"

print(os.path.join(os.path.dirname(__file__)))
print(os.path.join(os.path.dirname(__file__),"SHARES",USER))

def menu(do_while=False):
	if do_while: print(do_while)

menu(True)

