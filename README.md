# Game Of Life
This is an implementation of "Conway's Game of Life" in Bash scripting language for the "RISC-V Code Base" position.
Author: Alp Efe Karalar

## About

Conway's Game of Life is a cellular automaton on a 2D grid where each cell is either alive or dead. The grid evolves in discrete generations according to four rules applied simultaneously to every cell, based on its eight neighbors:

1. A live cell with fewer than 2 live neighbors dies (underpopulation).
2. A live cell with 2 or 3 live neighbors survives.
3. A live cell with more than 3 live neighbors dies (overpopulation).
4. A dead cell with exactly 3 live neighbors becomes alive (reproduction).


This implementation runs entirely in Bash, with no external dependencies beyond a POSIX-compliant terminal. It supports interactive pattern insertion, save/load, and a curated library of well-known Life patterns organized by category (still lifes, oscillators, spaceships).

## Quick Start

```bash
chmod +x game_of_life.sh
./game_of_life.sh -r       # start with a random grid
./game_of_life.sh -e       # start with an empty grid
./game_of_life.sh -l 1     # load preset 1
./game_of_life.sh -f grid1.txt  # load a previously saved grid
./game_of_life.sh -h       # help
```

While running, press `p` to pause. While paused, move the cursor with `h`/`j`/`k`/`l` (VIM bindings) and insert patterns with `i` (pixel), `b` (basic still life), `o` (oscillator), or `s` (spaceship). Press `w` to save the current grid to a numbered file.

## Implementation Notes

### Grid representation

Bash does not have native 2D arrays, so the grid is stored as a 1D array with manual indexing. The `index` helper converts (row, col) to a flat index using `row * cols + col`. This keeps the array operations cheap and avoids the awkwardness of associative arrays for what is fundamentally a dense numeric grid.

### Generations must be computed out-of-place

The core constraint of Game of Life is that every cell in generation N+1 depends on its neighbors in generation N. Updating cells in place would corrupt the neighbor counts of cells not yet processed. The `loop` function handles this by allocating a `next` array, computing all updates against the current `grid`, then assigning `grid=("${next[@]}")` at the end.

### Iteration and recursion

The challenge prompt asks the candidate to identify sections demonstrating recursion or iteration. **This implementation is entirely iterative.** Specifically:

- **`loop`** iterates over every cell in the grid, computing the next generation. This is the main simulation step.
- **`count_neighbors`** iterates over the 3×3 neighborhood of a cell (skipping the center).
- **`display`** iterates over the grid row by row to build the output frame.
- **`main`** runs an infinite outer loop, reading one keypress per tick.

Game of Life is a natural fit for iteration because each generation is a uniform pass over a finite grid. Recursion would be possible (for example, recursively flooding connected live regions to identify components) but unnecessary and slower for the core simulation. By contrast, a problem like Tower of Hanoi is naturally recursive because the structure of the solution mirrors itself at each level of reduction.

### Flicker mitigation

Naively redrawing the screen with `clear` and `printf` causes visible flicker because the terminal repaints incrementally. The `display` function avoids this by building the entire next frame as a single string (`frame`), then writing it in one `printf` call using the ANSI escape `\e[H\e[J` to move the cursor home and clear from there. This effectively performs double-buffering in user space.

### Pattern library

Patterns are organized into three categories and implemented as small functions that call `set_cell` at hard-coded offsets relative to a (row, col) anchor. The categorization mirrors standard Life taxonomy:

- **Still lifes** (don't change): block, beehive, loaf, boat, tub
- **Oscillators** (return to original state after a period): blinker, toad, beacon, pulsar, penta-decathlon
- **Spaceships** (translate across the grid): glider, LWSS, MWSS, HWSS

## Limitations and Future Work

The grid is currently fixed at 20×95 to keep terminal sizing predictable; dynamic resizing is listed in the feature roadmap. Methuselahs (long-lived chaotic patterns like R-pentomino and Acorn) and gun patterns (Gosper, Simkin) are stubs for future work. No bounds-wrapping is implemented — the grid is hard-edged rather than toroidal.

## Use of Generative AI

I used Claude (Anthropic) during development as a tool for the following:

- **Bash documentation lookups** — quick clarification on idioms like namerefs (`local -n`), arithmetic expansion (`$(( ))`), and ANSI escape sequences.
- **Brainstorming the architecture** — talking through how to represent the grid, where to put the out-of-place update logic, and how to structure the pattern-insertion menus.
- **Debugging existing code** — pasting in functions that weren't behaving and asking what was going on (most often: arithmetic that I forgot to wrap in `$(( ))`).

All meaningful code was written by me. No code was generated by an AI and pasted in unmodified. I am disclosing this because I value intellectual honesty and because I think it is the right norm for open-source contributions. I can share the conversation if requested.

## Features
- [x] Display static grid on terminal (24 x 96)
- [x] Start Game of Life with predetermined shape (Slider)
- [x] Ability to start the game of life with predetermined patterns
  - [x] Empty grid 
  - [x] Random grid 
  - [x] Set grids (#TODO: Add more)
- [x] Ability to add new shapes to the grid 
  - [x] Add pausing capability to add new shapes with the key `p`
  - [x] Add a cursor that can be moved with VIM keys (`hjkl`) when paused
  - [x] Add ability to choose simple shape to insert while paused 
    - 'i' for pixel 
    - 'b' for basic static shapes 
    - 'o' for oscilating shapes 
    - 's' for spaceships 
  - [ ] Extend shapes and add "number followed by shape insertion" logic 
    - [x] Basic (static) shapes
      - [x] Block
      - [x] Beehive
      - [x] Loaf
      - [x] Boat
      - [x] Tub
    - [x] Oscilators
      - [x] Blinker
      - [x] Toad
      - [x] Beacon
      - [x] Pulsar
      - [x] Penta-decathlon 
    - [x] Spaceships
      - [x] Glider
      - [x] LWSS
      - [x] MWSS
      - [x] HWSS
    - [ ] Methuselahs
      - [ ] Print message 
      - [ ] R-pentomino
      - [ ] Diehard
      - [ ] Acorn
    - [ ] Guns (could be templates instead of shapes)
      - [ ] Gosper glider gun 
      - [ ] Simkin glider gun 
- [x] Add the ability to save a grid and load it later (Important)
- [x] Add borders to indicate the fixed size of the space
- [x] Fix flickering 
- [x] Fix printed messages
- [ ] Adjust display dimensions size dynamically to the terminal size (REACH)
- [ ] Add the ability to display a shadow of the shape to be placed (REACH)
