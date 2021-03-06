# game-of-life.gb

An implementation of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) for the Game Boy, written in LR35902 (Z80-like) assembler


<img src="https://user-images.githubusercontent.com/1031558/69206103-654b3a80-0b11-11ea-9aaa-30681de58b0d.gif" width="320" height="288">


## Implementation

Uses the standard current/sucessor buffer approach. Each cell = 1 bit.

A faux framebuffer approach is used. A large grid size is possible, but optimizations are needed.

## Building

The Game Boy assembler [RGBDS](https://github.com/rednex/rgbds/) is needed.

### Linux/Mac OS

Build and install as specified on the `RGBDS` project site.

Run `make -B`

### Windows

From the shell for the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10), install `RGBDS`.

Run either `make` from the WSL shell or `wsl make -B` from PowerShell.

### Test Mode

    framebuffer tests

    - flood fill: `make test1 -B`


### Output

Build targets are created in folder `build`. These include:

* rom file
* debug symbols

## Tools

* [RGBDS Z80](https://github.com/DonaldHays/rgbds-vscode) VS Code extension

* [BGB](http://bgb.bircd.org/) emulator/debugger for the Game Boy

## Resources

* [Awesome Game Boy Development](https://github.com/avivace/awesome-gbdev)
