## Introduction

This is a sokoban clone made using ruby2d.

![Round 'n Round level](/screenshots/level.png)

## Setup

Clone this repository with your prefered method.

Run bundle install to make sure you have ruby (3.0.0) the Ruby2d v0.9.5 gem installed.

````
bundle install
````

To get the game up and running:

````
ruby sokoban.rb
````

## Levels

Levels are loaded in order and they follow the common [sokoban representation](http://www.sokobano.de/wiki/index.php?title=Level_format).

|     Object      |   Character   |
| --------------- | ------------- |
|      Wall       |       #       |
|      Player     |       @       |
|  Player on goal |       +       |
|       Box       |       $       |
|   Box on goal   |       *       |
|      Goal       |       .       |
|      Floor      |        (Space)|

- Levels are currently limited to be 20 x 20 max, but `@max_cell_width` and `@max_cell_height` can be modified in `lib/logic/level_manager.rb`

- First line in a level file represents the level name

- Lines after the level should not have `#` and will be ignored by the Level Manager when drawing the level

- Add your own level files to the `/levels` directory. Levels will be shown in alphabetical order

## Tasks

- [ ] Update code to current Ruby2d version
- [ ] Create and add additional sound and music
- [ ] Create and add additional sprites and animations
- [ ] Create a parser for different level file formats? (.sok, .xsb, RLE, .tsb, .hsb, .txt, ...?)
- [ ] Create fun levels \o/