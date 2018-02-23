#!/bin/bash
# Copyright (c) 2013-2018 Yu-Jie Lin
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


# constants
M=32768
M1=32767
MP=$((M / 100))


init()
{
  local x

  W=$(tput cols)
  declare -ga B=()

  for ((x=0; x<W; x++)); do
    B[x]=$RANDOM
  done
}


step()
{
  local N Bx x=$1

  Bx=${B[x]}

  # jittering +/- (0% to 25%) of B[x]
  ((
    Bx += (3 * RANDOM / M - 1) * Bx * (25 * RANDOM / M) / 100,
    Bx = Bx > M1 ? M1 : Bx,
    Bx = Bx <  0 ?  0 : Bx
  ))

  # smoothing out Bx (weight = 1) with two neighboring tiles (weight = 1)
  ((
    N = ((x ? B[x - 1] : Bx) + (x < W - 1 ? B[x + 1] : Bx)) / 2,
    Bx = (N + Bx) / 2
  ))

  # 1% chance to be random-like spots
  ((
    RANDOM < MP &&
    (
      Bx += (3 * RANDOM / M - 1) * (Bx < MP ? MP : Bx) * RANDOM / M,
      Bx = Bx > M1 ? M1 : Bx,
      Bx = Bx <  0 ?  0 : Bx,
      Bx = (N + Bx) / 2
    )
  ))

  B[x]=$Bx
}


main()
{
  local x BT
  declare -a L

  init

  stty -echo
  tput civis
  while REPLY=; read -t 0.1 -n 1 2>/dev/null; [[ -z $REPLY ]]; do
    for ((x = 0; x < W; x++)); do
      step $x
      BT=${B[x]}
      step $x
      L[x]="\e[38;2;0;0;$((BT / 128))m\e[48;2;0;0;$((B[x] / 128))m▀"
    done

    echo
    printf "%b" "${L[@]}"
    echo -ne "\e[0m"
  done
  tput cnorm
  stty echo
}


main
