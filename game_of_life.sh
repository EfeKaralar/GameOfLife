#!/opt/homebrew/bin/bash
# For MacOS ^^
#!/bin/bash
# For Linux ^^
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
# Example usage to get the idx at (3, 5)
# index idx 3 5:
index() {
  local -n result=$1 # nameref
  local row=$2
  local col=$3

  result=$(($row * $cols + $col))
}

# Function to set a cell to 1
# Need to pass the row index, col index
set_cell() {
  local r=$1
  local c=$2
  index idx $r $c
  grid[$idx]=1
}

# display grid function
# TODO:
# 1. Fix Flicker
# 2. Add dynamic scaling (reach goal)
display() {
  printf '\e[H'
  for ((r = 0; r < $rows; r++)); do
    for ((c = 0; c < $cols; c++)); do
      index idx $r $c
      cell=${grid[$idx]}
      [[ $cell -eq 1 ]] && printf '#' || printf ' '
    done
  done
}

count_neighbors() {
  local -n result=$1 # nameref
  local r=$2 c=$3
  for ((i = -1; i < 2; i++)); do
    for ((j = -1; j < 2; j++)); do
      # Skip the main cell
      ((r == 0 && j == 0)) && continue
      local nr=$((r + i))
      local nc=$((c + j))
      # Out of bond check
      ((nr < 0 || nr >= rows || nc < 0 || nc >= cols)) && continue
      index idx $nr $nc
      cell=${grid[$idx]}
      [[ $cell -eq 1 ]] && ((result++))
    done
  done
}

# Place glider centered around row 5, col 10
set_cell 5 11
set_cell 6 12
set_cell 7 10
set_cell 7 11
set_cell 7 12

while true; do
  display
  for ((r = 0; r < rows; r++)); do
    for ((c = 0; c < cols; c++)); do
      count_neighbors neighbors $r $c
      index idx $r $c
      # if neighbors < 2 OR > 3; die
      # if neighbors == 2; continue life
      # if neighbors == 3; be born
    done
  done
done
# index idx 2 3
# echo $idx
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
