# Game Of Life

This is an implementation of "Conway's Game of Life" in Bash scripting language for the "RISC-V Code Base" position.

Author: Alp Efe Karalar

## Features
- [x] Display static grid on terminal (24 x 96)
- [x] Start Game of Life with predetermined shape (Slider)
- [x] Ability to start the game of life with predetermined patterns
  - [x] Empty grid 
  - [x] Random grid 
  - [x] Set grids (#TODO: Add more)
- [ ] Ability to add new shapes to the grid 
  - [ ] Add pausing capability to add new shapes 
  - [ ] Add a cursor that can be moved with VIM keys (`hjkl`) when paused
  - [ ] Add ability to choose shape to insert while paused 
    - 'b' for basic static shapes 
    - 'o' for oscilating shapes 
    - 's' for spaceships 
  - [ ] Extend shapes and add "number followed by shape insertion" logic 
- [ ] Adjust display dimensions size dynamically to the terminal size (REACH)
- [ ] Fix flickering (REACH)
