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


init()
{
  W=$(tput cols)
  declare -ga B=() T_CELLS=()

  local x
  for ((x = 0; x < W; x++)); do
    ((B[x] = RANDOM))
    ((T_CELLS[x] = RANDOM % 2))
  done
  RULE_NO=${1:-150}
}


step()
{
  local x curr
  declare -a N_CELLS=()
  for ((x = 0; x < W; x++)); do
    # if next state is:
    #   0: blue value - 10% of RANDOM
    #   1: blue value + 10% of RANDOM
    ((
      curr = T_CELLS[(x + W - 1) % W] << 2
           | T_CELLS[x]               << 1
           | T_CELLS[(x + 1)     % W],
      N_CELLS[x] = (RULE_NO >> curr) & 1,
      B[x] += (RANDOM / 10) * (N_CELLS[x] * 2 - 1),
      B[x] = B[x] <     0 ?     0 : B[x],
      B[x] = B[x] > 32767 ? 32767 : B[x]
    ))
  done

  # smooth out and like T_CELLS, B is also a cyclic tag system, warping around
  for ((x = 0; x < W; x++)); do
    ((B[x] = (B[(x + W - 1) % W] + B[(x + 1) % W]) / 4 + B[x] / 2))
  done
  T_CELLS=("${N_CELLS[@]}")
}


main()
{
  init "$@"
  stty -echo
  tput civis

  local x
  declare -a L TB
  while REPLY=; read -t 0.1 -n 1 2>/dev/null; [[ -z $REPLY ]]; do
    step
    TB=("${B[@]}")
    step
    for ((x = 0; x < W; x++)); do
      L[x]="\e[38;2;0;0;$((TB[x] / 128))m\e[48;2;0;0;$((B[x] / 128))m▀"
    done
    echo
    printf "%b" "${L[@]}"
    echo -ne "\e[0m"
  done
  tput cnorm
  stty echo
}


main "$@"
