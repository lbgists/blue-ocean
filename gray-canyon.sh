#!/bin/bash
# Copyright (c) 2013 Yu-Jie Lin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

W=$(tput cols)

for ((x=0; x<W; x++)); do
  V[x]=$RANDOM
done

while :; do
  for ((x=0; x<W; x++)); do
    ((
      _L = x         ? V[x - 1] : RANDOM,
      _R = x < W - 1 ? V[x + 1] : RANDOM,
      V[x] = (_L + V[x] + _R) / 3
    ))
    ((
      V[x] = RANDOM % 2
           ? V[x] * 11 / 10
           : V[x] *  9 / 10,
      V[x] = V[x] > 32767
           ? 32767
           : V[x]
    ))
    echo -ne "\e[48;5;$((232 + V[x] * 16 / 32768))m "
  done
  sleep 0.01
  echo
done
