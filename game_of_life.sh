#!/usr/bin/env bash

############ SET UP ######################
# Right now, setting the terminal dimensions manually will be easier for us
rows=20
cols=95

paused=1 # 0: false - 1: true
grid=($(printf '0%.0s ' $(seq 1 $((rows * cols)))))
mode="empty"
preset_num=1
cursor_c=0
cursor_r=0

footer_msg=""

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
      footer_msg="Empty grid"
      ;;
    -r)
      mode="random"
      setup_grid $mode
      footer_msg="Grid randomly initialized"
      ;;

    -l)
      mode="preset"
      preset_num=$2
      shift
      setup_grid $mode $preset_num
      footer_msg="Loaded preset $p"
      ;;
    -f)
      mode="file"
      filename=$2
      shift
      setup_grid $mode $filename
      footer_msg="Loaded file $p"
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
  -f [file] Load the grid layout saved in [file]. [file] must be txt file
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
  ((r >= 0 && r < rows && c >= 0 && c < cols)) && grid[$idx]=1
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
  file)
    # Load the file if file exists, otherwise error
    # WARNING: No validity checking for file! Only input valid files!
    if [[ -f $p ]]; then
      grid=($(cat $p))

    else
      printf "Please enter a valid file name"
      exit 1
    fi
    ;;

  esac

}

# display grid function
# TODO:
# [x] Fix Flicker
# [x] Add borders to indicate the fixed size of terminal
# (ABANDONED) Add dynamic scaling (reach goal)
display() {
  local frame=''
  frame+='\e[H\e[J' # home, then erase from cursor to end of screen
  # frame+='\e[H'     # cursor to home
  for ((r = 0; r < $rows; r++)); do
    for ((c = 0; c < $cols; c++)); do
      index idx $r $c
      cell=${grid[$idx]}
      if ((paused && cursor_r == r && cursor_c == c)); then
        frame+='@'
      else
        [[ $cell -eq 1 ]] && frame+='#' || frame+=' '
      fi
    done
    frame+='|\n' # '|' is used for vertical border
  done
  printf '%b' "$frame"
  print_bottom_border
  display_footer

}

print_bottom_border() {
  # print the bottom border
  printf '─%.0s' $(seq 1 $cols)
  printf '─\n'
}

display_footer() {
  if ((paused)); then
    printf "PAUSED | p: unpause | hjkl: move cursor | i: pixel | b: basic | o: oscillator | s: spaceship | w: save\n"
  else
    printf "RUNNING | p: pause\n"
  fi
  printf "%s\n" "$footer_msg"
  printf "Cursor: (%d, %d)" $cursor_r $cursor_c
}

count_neighbors() {
  local -n result=$1 # nameref
  local r=$2 c=$3
  for ((i = -1; i < 2; i++)); do
    for ((j = -1; j < 2; j++)); do
      # Skip the selected cell
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

save_grid() {
  local i=1
  while [[ -f "grid${i}.txt" ]]; do
    ((i++))
  done
  echo "${grid[@]}" >"grid${i}.txt"
  footer_msg="Saved to grid${i}.txt"
}

main() {
  parse_flags "$@"
  while true; do
    display
    read -r -t 0.2 -n 1 key
    # printf "KEY: '%s' PAUSED: %d\n" "$key" "$paused" # temporary debug line
    case $key in
    p)
      paused=$((!paused))
      ;;
    h) ((cursor_c > 0)) && ((cursor_c--)) ;;
    l) ((cursor_c < cols - 1)) && ((cursor_c++)) ;;
    k) ((cursor_r > 0)) && ((cursor_r--)) ;;
    j) ((cursor_r < rows - 1)) && ((cursor_r++)) ;;
    # Insert shapes when paused
    i)
      ((paused)) && set_cell cursor_r cursor_c
      ;;
    b)
      ((paused)) && select_basic_shape
      ;;
    o)
      ((paused)) && select_oscilator
      ;;
    s)
      ((paused)) && select_spaceship
      ;;
    w)
      ((paused)) && save_grid
      ;;
    esac
    ((!paused)) && loop
  done
}

############# SHAPES ##############
######## STATIC SHAPES ############
select_basic_shape() {
  # step 1: show options
  footer_msg="BASIC: 1: block | 2: beehive | 3: loaf | 4: boat | 5: tub"
  display # redraw so the message appears before waiting for input

  # step 2: read 1 keypress
  read -r -n 1 shape_key
  # step 3: case on shape_key
  case $shape_key in
  1)
    block grid $cursor_r $cursor_c
    footer_msg="Placed: block"
    ;;
  2)
    beehive grid $cursor_r $cursor_c
    footer_msg="Placed: beehive"
    ;;
  3)
    loaf grid $cursor_r $cursor_c
    footer_msg="Placed: loaf"
    ;;
  4)
    boat grid $cursor_r $cursor_c
    footer_msg="Placed: boat"
    ;;
  5)
    tub grid $cursor_r $cursor_c
    footer_msg="Placed: tub"
    ;;
  *) footer_msg="Cancelled" ;;
  esac
}
# Block
block() {
  local -n grid=$1
  local r=$2 c=$3
  set_cell $r $c
  set_cell $((r + 1)) $c
  set_cell $r $((c + 1))
  set_cell $((r + 1)) $((c + 1))
}

# Beehive
beehive() {
  local -n grid=$1
  local r=$2 c=$3
  set_cell $r $((c + 1))
  set_cell $r $((c + 2))
  set_cell $((r + 1)) $((c))
  set_cell $((r + 1)) $((c + 3))
  set_cell $((r + 2)) $((c + 1))
  set_cell $((r + 2)) $((c + 2))
}

# Loaf
loaf() {
  local -n grid=$1
  local r=$2 c=$3
  set_cell $r $((c + 1))
  set_cell $r $((c + 2))
  set_cell $((r + 1)) $((c))
  set_cell $((r + 1)) $((c + 3))
  set_cell $((r + 2)) $((c + 1))
  set_cell $((r + 2)) $((c + 3))
  set_cell $((r + 3)) $((c + 2))
}

boat() {
  local -n grid=$1
  local r=$2 c=$3
  set_cell $r $c
  set_cell $((r + 1)) $c
  set_cell $r $((c + 1))
  set_cell $((r + 1)) $((c + 2))
  set_cell $((r + 2)) $((c + 1))
}

tub() {
  local -n grid=$1
  local r=$2 c=$3
  set_cell $((r + 1)) $c
  set_cell $r $((c + 1))
  set_cell $((r + 1)) $((c + 2))
  set_cell $((r + 2)) $((c + 1))
}

######## OSCILATORS ###############
select_oscilator() {
  # step 1: show options
  footer_msg="OSCILLATORS: 1: blinker | 2: toad | 3: beacon | 4: pulsar | 5: penta-decathlon"
  display
  # step 2: read 1 keypress
  read -r -n 1 shape_key
  # step 3: case on shape_key
  case $shape_key in
  1)
    blinker grid $cursor_r $cursor_c
    footer_msg="Placed: blinker"
    ;;
  2)
    toad grid $cursor_r $cursor_c
    footer_msg="Placed: toad"
    ;;
  3)
    beacon grid $cursor_r $cursor_c
    footer_msg="Placed: beacon"
    ;;
  4)
    pulsar grid $cursor_r $cursor_c
    footer_msg="Placed: pulsar"
    ;;
  5)
    penta_decathlon grid $cursor_r $cursor_c
    footer_msg="Placed: penta-decathlon"
    ;;
  *) footer_msg="Cancelled" ;;

  esac
}

blinker() {
  local -n g=$1
  local r=$2 c=$3
  set_cell $r $c
  set_cell $r $((c + 1))
  set_cell $r $((c + 2))
}

toad() {
  local -n g=$1
  local r=$2 c=$3
  set_cell $((r)) $((c + 1))
  set_cell $((r)) $((c + 2))
  set_cell $((r)) $((c + 3))
  set_cell $((r + 1)) $((c))
  set_cell $((r + 1)) $((c + 1))
  set_cell $((r + 1)) $((c + 2))
}

beacon() {
  local -n g=$1
  local r=$2 c=$3
  # Top left
  set_cell $((r)) $((c))
  set_cell $((r)) $((c + 1))
  set_cell $((r + 1)) $((c))
  # Top right
  set_cell $((r + 3)) $((c + 3))
  set_cell $((r + 2)) $((c + 3))
  set_cell $((r + 3)) $((c + 2))
}

pulsar() {
  local -n g=$1
  local r=$2 c=$3
  # Top left shape
  ## Top start 2, 4
  set_cell $((r + 2)) $((c + 4))
  set_cell $((r + 2)) $((c + 5))
  set_cell $((r + 2)) $((c + 6))
  ## Left start  4, 2
  set_cell $((r + 4)) $((c + 2))
  set_cell $((r + 5)) $((c + 2))
  set_cell $((r + 6)) $((c + 2))
  ## Right start  4, 7
  set_cell $((r + 4)) $((c + 7))
  set_cell $((r + 5)) $((c + 7))
  set_cell $((r + 6)) $((c + 7))
  ## Bot start 7, 4
  set_cell $((r + 7)) $((c + 4))
  set_cell $((r + 7)) $((c + 5))
  set_cell $((r + 7)) $((c + 6))

  # Top right shape
  ## Top start 2, 10
  set_cell $((r + 2)) $((c + 10))
  set_cell $((r + 2)) $((c + 11))
  set_cell $((r + 2)) $((c + 12))
  ## Left start  4, 9
  set_cell $((r + 4)) $((c + 9))
  set_cell $((r + 5)) $((c + 9))
  set_cell $((r + 6)) $((c + 9))
  ## Right start  4, 14
  set_cell $((r + 4)) $((c + 14))
  set_cell $((r + 5)) $((c + 14))
  set_cell $((r + 6)) $((c + 14))
  ## Bot start 7, 10
  set_cell $((r + 7)) $((c + 10))
  set_cell $((r + 7)) $((c + 11))
  set_cell $((r + 7)) $((c + 12))

  # Bot left shape
  ## Top start 9, 4
  set_cell $((r + 9)) $((c + 4))
  set_cell $((r + 9)) $((c + 5))
  set_cell $((r + 9)) $((c + 6))
  ## Left start  10, 2
  set_cell $((r + 10)) $((c + 2))
  set_cell $((r + 11)) $((c + 2))
  set_cell $((r + 12)) $((c + 2))
  ## Right start  10, 7
  set_cell $((r + 10)) $((c + 7))
  set_cell $((r + 11)) $((c + 7))
  set_cell $((r + 12)) $((c + 7))
  ## Bot start 14, 4
  set_cell $((r + 14)) $((c + 4))
  set_cell $((r + 14)) $((c + 5))
  set_cell $((r + 14)) $((c + 6))

  # Bot Right Shape
  ## Top start  9, 10
  set_cell $((r + 9)) $((c + 10))
  set_cell $((r + 9)) $((c + 11))
  set_cell $((r + 9)) $((c + 12))
  ## Left Start  10, 9
  set_cell $((r + 10)) $((c + 9))
  set_cell $((r + 11)) $((c + 9))
  set_cell $((r + 12)) $((c + 9))
  ## Right start  10, 14
  set_cell $((r + 10)) $((c + 14))
  set_cell $((r + 11)) $((c + 14))
  set_cell $((r + 12)) $((c + 14))
  ## Bot start 14, 10
  set_cell $((r + 14)) $((c + 10))
  set_cell $((r + 14)) $((c + 11))
  set_cell $((r + 14)) $((c + 12))
}

penta_decathlon() {
  local -n g=$1
  local r=$2 c=$3
  # Top shape
  ## Row 1 (Starts at (3, 4)
  set_cell $((r + 3)) $((c + 4))
  set_cell $((r + 3)) $((c + 5))
  set_cell $((r + 3)) $((c + 6))
  ## Row 2 and 3
  set_cell $((r + 4)) $((c + 5))
  set_cell $((r + 5)) $((c + 5))
  ## Row 4 (Starts at (4, 6))
  set_cell $((r + 6)) $((c + 4))
  set_cell $((r + 6)) $((c + 5))
  set_cell $((r + 6)) $((c + 6))

  # Middle shape (Starts at (4, 8))
  set_cell $((r + 8)) $((c + 4))
  set_cell $((r + 8)) $((c + 5))
  set_cell $((r + 8)) $((c + 6))
  set_cell $((r + 9)) $((c + 4))
  set_cell $((r + 9)) $((c + 5))
  set_cell $((r + 9)) $((c + 6))

  # Bottom shape
  ## Row 1 (Starts at (4, 10))
  set_cell $((r + 11)) $((c + 4))
  set_cell $((r + 11)) $((c + 5))
  set_cell $((r + 11)) $((c + 6))
  ## Row 2 and 3
  set_cell $((r + 12)) $((c + 5))
  set_cell $((r + 13)) $((c + 5))
  ## Row 4 (Starts at (4, 13))
  set_cell $((r + 14)) $((c + 4))
  set_cell $((r + 14)) $((c + 5))
  set_cell $((r + 14)) $((c + 6))
}
######## SPACESHIPS ###############
select_spaceship() {
  # step 1: show options
  footer_msg="SPACESHIPS: 1: glider | 2: lwss | 3: mwss | 4: hwss"
  display

  # step 2: read 1 keypress
  read -r -n 1 shape_key
  # step 3: case on shape_key
  case $shape_key in
  1)
    glider grid $cursor_r $cursor_c
    footer_msg="Placed: glider"
    ;;
  2)
    lwss grid $cursor_r $cursor_c
    footer_msg="Placed: lwss"
    ;;
  3)
    mwss grid $cursor_r $cursor_c
    footer_msg="Placed: mwss"
    ;;
  4)
    hwss grid $cursor_r $cursor_c
    footer_msg="Placed: hwss"
    ;;
  *) footer_msg="Cancelled" ;;
  esac
}

glider() {
  local -n g=$1
  local r=$2 c=$3
  set_cell $((r)) $((c + 1))
  set_cell $((r + 1)) $((c + 2))
  set_cell $((r + 2)) $((c))
  set_cell $((r + 2)) $((c + 1))
  set_cell $((r + 2)) $((c + 2))
}

lwss() {
  local -n g=$1
  local r=$2 c=$3
  # Row 1
  set_cell $((r)) $((c))
  set_cell $((r)) $((c + 3))
  # Row 2
  set_cell $((r + 1)) $((c + 4))
  # Row 3
  set_cell $((r + 2)) $((c))
  set_cell $((r + 2)) $((c + 4))
  # Row 4
  set_cell $((r + 3)) $((c + 1))
  set_cell $((r + 3)) $((c + 2))
  set_cell $((r + 3)) $((c + 3))
  set_cell $((r + 3)) $((c + 4))
}

mwss() {
  local -n g=$1
  local r=$2 c=$3
  # Row 1
  set_cell $((r)) $((c + 1))
  set_cell $((r)) $((c + 2))
  set_cell $((r)) $((c + 3))
  set_cell $((r)) $((c + 4))
  set_cell $((r)) $((c + 5))
  # Row 2
  set_cell $((r + 1)) $((c))
  set_cell $((r + 1)) $((c + 5))
  # Row 3
  set_cell $((r + 2)) $((c + 5))
  # Row 4
  set_cell $((r + 3)) $((c))
  set_cell $((r + 3)) $((c + 4))
  # Row 5
  set_cell $((r + 4)) $((c + 2))
}

hwss() {
  local -n g=$1
  local r=$2 c=$3
  # Row 1
  set_cell $((r)) $((c + 1))
  set_cell $((r)) $((c + 2))
  set_cell $((r)) $((c + 3))
  set_cell $((r)) $((c + 4))
  set_cell $((r)) $((c + 5))
  set_cell $((r)) $((c + 6))
  # Row 2
  set_cell $((r + 1)) $((c))
  set_cell $((r + 1)) $((c + 6))
  # Row 3
  set_cell $((r + 2)) $((c + 6))
  # Row 4
  set_cell $((r + 3)) $((c))
  set_cell $((r + 3)) $((c + 5))
  # Row 5
  set_cell $((r + 4)) $((c + 2))
  set_cell $((r + 4)) $((c + 3))
}
############# MAIN FUNCTION ###########
main "$@"
