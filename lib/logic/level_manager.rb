require_relative '../game_objects/player'
require_relative '../game_objects/box'
require_relative '../game_objects/goal'
require_relative '../game_objects/floor'
require_relative '../game_objects/wall'

# TODO: Level Manager should have a parser for different file formats
# this class should be responsible for tracking the levels played,
# parsing the files, drawing the levels (creating the objects and adding them to the collider)
class LevelManager

    attr_reader :level_title, :cell_size, :max_cell_width, :max_cell_height

    def initialize
        @levels = Dir.children('levels')
        @levels_path = File.join(Dir.pwd, 'levels')
        @index = 0
        @max_cell_width = 20
        @max_cell_height = 20
        @cell_size = 32
    end

    # load level from /levels in order
    # collider register objects, x and y offset represent any kind of margin the level has
    def load_level(collider, x_offset, y_offset)
        # read the current index file in @levels
        level_file = File.readlines(File.join(@levels_path, @levels[@index]), chomp: true)

        level = []


        # analyse file
        level_file.each_index do |i|
            # We defined that for our custom created txt files, the first line will always be the title of the level
            if i == 0
                @level_title = level_file[i]
            end
            # lines that have a wall (#) are considered part of the level map, therefore should be added to level
            if i > 0 && level_file[i].include?('#')
                # these should be drawn 
                level << level_file[i].split('')
            end
        end

        # determines the level width and height according to characters and number of lines
        level_cell_height = level.count
        level_cell_width = level.map {|element| element.count}.max

        # right now we are returning if the level is greater than the canvas limit,
        # but this should really raise an error or load the next level
        return if greater_than_canvas(level_cell_width, level_cell_height)

        # which cell we should start drawing the tiles
        x_cell_offset = (@max_cell_width / 2) - (level_cell_width / 2)
        y_cell_offset = (@max_cell_height / 2) - (level_cell_height / 2)

        # first x and y considering all offsets
        x = x_offset + (x_cell_offset * @cell_size)
        y = y_offset + (y_cell_offset * @cell_size)

        # draw level - create all sprites and add them to the collider if necessary
        self.draw(level, collider, x, y)
        @index += 1
    end

    def draw(level, collider, x, y)
        init_x = x
        level.each do |row|
            x = init_x
            row.each_index do |i|
                case row[i]
                when '#'
                    wall = Wall.new(x, y, @cell_size)
                    collider << wall
                when ' ', '_', '-'
                    # spaces outside wall perimeter are ignored
                    unless i < row.index('#') || i > row.rindex('#')
                        floor = Floor.new(x, y, @cell_size)
                        collider << floor
                    end
                when '@', 'p'
                    floor = Floor.new(x, y, @cell_size)
                    player = Player.new(x, y, @cell_size)
                    collider << wall
                    collider << player
                when '+', 'P'
                    floor = Floor.new(x, y, @cell_size)
                    goal = Goal.new(x, y, @cell_size)
                    player = Player.new(x, y, @cell_size)
                    collider << wall
                    collider << goal
                    collider << player
                when '$', 'b'
                    floor = Floor.new(x, y, @cell_size)
                    box = Box.new(x, y, @cell_size)
                    collider << wall
                    collider << box
                when '*', 'B'
                    floor = Floor.new(x, y, @cell_size)
                    goal = Goal.new(x, y, @cell_size)
                    box = Box.new(x, y, @cell_size)
                    collider << wall
                    collider << goal
                    collider << box
                when '.'
                    floor = Floor.new(x, y, @cell_size)
                    goal = Goal.new(x, y, @cell_size)
                    collider << wall
                    collider << goal
                else
                    puts "unknown symbol #{cell}"
                end

                x += @cell_size
            end
            y += @cell_size
        end
    end

    def reset_level_index
        @index = 0
    end

    def no_more_levels
        @index >= @levels.count
    end

private

    def greater_than_canvas(w,h)
        w > @max_cell_width || h > @max_cell_height
    end

end