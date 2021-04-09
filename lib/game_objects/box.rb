require 'ruby2d'
require_relative './helpers/movable'

class Box < Movable

    def initialize(x, y, size)
        @@total_pushes = 0
        sprite = Square.new(x: x, y: y, z: 2, size: size, color: '#ffb833')
        super(sprite, size)
    end

    def change_sprite(type)
        if type == 'on goal'
            sprite.color = '#ff0099'
        else
            sprite.color = '#ffb833'
        end
    end

    def end_movement
        super
        add_push
    end

    def add_push
        @@total_pushes += 1
    end

    def self.add_push
        @@total_pushes += 1
    end

    def self.remove_push
        @@total_pushes -= 1
    end

    def self.reset_pushes
        @@total_pushes = 0
    end

    def self.total_pushes
        @@total_pushes
    end
end