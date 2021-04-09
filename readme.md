## Introduction

This is a still in development sokoban clone made using ruby2d.

![Round 'n Round level](/screenshots/level.png)

## Setup

Make sure you have the ruby2d gem installed.

````
gem install ruby2d
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

## Tasks

- [ ] Create and add additional sound and music
- [ ] Create and add additional sprites and animations
- [ ] Create a parser for different level file formats? (.sok, .xsb, RLE, .tsb, .hsb, .txt, ...?)
- [ ] Create fun levels \o/