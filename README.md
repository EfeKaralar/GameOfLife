# Game Of Life

This is an implementation of "Conway's Game of Life" in Bash scripting language for the "RISC-V Code Base" position.

Author: Alp Efe Karalar

** Warning: ** Currently only works with a 24 x 96 terminal resolution. Please resize your terminal to fit it.

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
