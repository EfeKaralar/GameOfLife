#!/bin/bash
# Set total row & col count to the dimensions of the terminal
# Have 2 cols empty to display status etc.
# cols=$(tput cols)
# rows=$(($(tput lines) - 2))
#
# Right now, setting it manually will work and be easier for us
rows=24
cols=96
echo "Set dimensions to $rows X $cols"
# initialize grid to all zeros
grid=($(printf '0%.0s ' $(seq 1 $((rows * cols)))))

# Functıon to the index of an item at a row and column
# Need to pass the row index, col index
index() {
  local row=$1
  local col=$2
  echo $(($row * $cols + $col))
}

# Function to set a cell to 1
# Need to pass the row index, col index
set_cell() {
  local r=$1 c=$2
  grid[$(index $r $c)]=1
}

# display grid function
# TODO: implenment
# display(){
#   printf '\e[H'
#   for ((r=0; r<$rows; r++)); do
#     for ((c=0; c<$cols; c++)); do
#       cell=${grid[]}
# }

# result=$(index 2 3)
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
# LOGIC
