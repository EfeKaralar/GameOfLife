#!/bin/bash

# Functıon to the index of an item at a row and column
# Need to pass the row index, col index, and total cols count
# in that exact order!
index() {
  local row=$1
  local col=$2
  local cols=$3
  echo $(($row * $cols + $col))
}

# result=$(index 2 3 5)
# echo $result
#
# PSEUDO CODE
# while true:
#   display grid
#   sleep
#   for each cell:
#     count neighbors in the CURRENT grid
#     write result to NEXT grid
#   copy NEXT grid -> CURRENT GRID
