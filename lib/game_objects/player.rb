require 'ruby2d'
require_relative './helpers/movable'
require_relative '../../config/game_config'

class Player < Movable

    attr_reader :steps

    def initialize(x, y, size)
        @steps = 0
        sprite = Square.new(x: x, y: y, z: 2, size: size, color: 'blue')
        super(sprite, size)
    end

    def set_destination_with_key(key)
        # handle presses only when player has stopped moving
        unless self.is_moving?
            case key
            when $game_config[:preferences][:controller][:left]
                x = -1
                y = 0
            when $game_config[:preferences][:controller][:right]
                x = 1
                y = 0
            when $game_config[:preferences][:controller][:up]
                x = 0
                y = -1
            when $game_config[:preferences][:controller][:down]
                x = 0
                y = 1
            else
                return
            end

            self.set_destination(x, y)
        end
    end

    def end_movement
        super
        add_step
    end

    def add_step
        @steps += 1
    end

    def remove_step
        @steps -= 1
    end

    def reset_steps
        @steps = 0
    end
end