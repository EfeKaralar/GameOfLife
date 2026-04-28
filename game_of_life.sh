#!/usr/bin/env bash

############ SET UP ######################
# Right now, setting the terminal dimensions manually will be easier for us
rows=24
cols=96
echo "Pause to insert shapes   p: pause/unpause | hjkl: move cursor"

# initialize grid to all zeros
paused=1 # 0: false - 1: true
grid=($(printf '0%.0s ' $(seq 1 $((rows * cols)))))
mode="empty"
preset_num=1

############ HELPER FUNCTIONS #############
parse_flags() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h)
      show_help
      exit 0
      ;;
    -e)
      mode="empty"
      setup_grid $mode
      ;;
    -r)
      mode="random"
      setup_grid $mode
      ;;

    -l)
      mode="preset"
      preset_num=$2
      shift
      setup_grid $mode $preset_num
      ;;
    *)
      show_help
      exit 1
      ;; # unknown flag
    esac
    shift # move to next argument
  done
}

show_help() {
  cat <<EOF
Usage: ./game_of_life [flag]
  -h        Show this help menu
  -e        Start with empty grid
  -r        Start with random pattern
  -l [n]    Load preset number n
              1: Block + Blinker + Glider
              2: To be implemented... 
              3: To be implemented  
EOF
}

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

setup_grid() {
  local m=$1
  local p=${2:-1}

  # initialize grid to all zeros
  grid=($(printf '0%.0s ' $(seq 1 $((rows * cols)))))
  case $m in

  empty)
    # do nothing
    :
    ;;

  random)
    local size=$((rows * cols))
    local shape r c
    # Put a random shape every 5-15 pixels
    for ((idx = 0; idx < size; idx += RANDOM % 10 + 5)); do
      shape=$((RANDOM % 3))
      r=$((idx / cols))
      c=$((idx % cols))
      case $shape in
      0)
        block grid $r $c
        ;;
      1)
        blinker grid $r $c
        ;;
      2)
        glider grid $r $c
        ;;
      esac
    done
    ;;

  preset)
    case $p in
    1)
      # A random shape I drew that uses all the objects so far
      # Place a box
      block grid 10 32
      # Place a blinker
      blinker grid 8 2
      # Place glider centered around row 5, col 10
      glider grid 5 10
      ;;
    *)
      printf "Please enter a valid preset number"
      exit 1
      ;;
    esac
    ;;
  esac

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
      ((i == 0 && j == 0)) && continue
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

loop() {
  declare -a next=("${grid[@]}")
  for ((r = 0; r < rows; r++)); do
    for ((c = 0; c < cols; c++)); do
      neighbors=0
      count_neighbors neighbors $r $c
      index idx $r $c
      # if neighbors < 2 OR > 3; die
      # if neighbors == 2; continue life
      # if neighbors == 3; be born
      [[ $neighbors -lt 2 || $neighbors -gt 3 ]] && next[$idx]=0
      [[ $neighbors -eq 2 ]] && next[$idx]=${grid[$idx]}
      [[ $neighbors -eq 3 ]] && next[$idx]=1
    done
  done
  grid=("${next[@]}")
  # sleep 0.2
}

main() {
  parse_flags "$@"
  while true; do
    display
    read -r -t 0.2 -n 1 key
    # printf "KEY: '%s' PAUSED: %d\n" "$key" "$paused" # temporary debug line
    [[ "$key" == "p" ]] && paused=$((!paused))
    ((!paused)) && loop
  done
}

############# SHAPES ##############
######## STATIC SHAPES ############
# Block
block() {
  local -n grid=$1
  local r=$2 c=$3
  index idx $r $c
  grid[$idx]=1
  ((c + 1 < cols)) && grid[$((idx + 1))]=1
  ((r + 1 < rows)) && grid[$((idx + cols))]=1
  ((c + 1 < cols && r + 1 < rows)) && grid[$((idx + cols + 1))]=1
}

############# SHAPES ##############
######## STATIC SHAPES ############
block() {
  local -n g=$1
  local r=$2 c=$3
  index idx $r $c
  g[$idx]=1
  ((c + 1 < cols)) && g[$((idx + 1))]=1
  ((r + 1 < rows)) && g[$((idx + cols))]=1
  ((c + 1 < cols && r + 1 < rows)) && g[$((idx + cols + 1))]=1
}

######## OSCILATORS ###############
blinker() {
  local -n g=$1
  local r=$2 c=$3
  index idx $r $c
  g[$idx]=1
  ((r + 1 < rows)) && g[$((idx + cols))]=1
  ((r + 2 < rows)) && g[$((idx + cols + cols))]=1
}
######## SPACESHIPS ###############
glider() {
  local -n g=$1
  local r=$2 c=$3
  index idx $r $c
  g[$((idx + 1))]=1
  ((r + 1 < rows && c + 2 < cols)) && g[$idx + cols + 2]=1
  ((r + 2 < rows)) && g[$idx + cols + cols]=1
  ((r + 2 < rows && c + 1 < cols)) && g[$idx + cols + cols + 1]=1
  ((r + 2 < rows && c + 2 < cols)) && g[$idx + cols + cols + 2]=1

}

############# MAIN FUNCTION ###########
main "$@"
