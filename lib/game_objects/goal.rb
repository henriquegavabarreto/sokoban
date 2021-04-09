require 'ruby2d'
require_relative './helpers/positioning'

class Goal
    
    include Positioning

    attr_reader :sprite

    def initialize(x, y, size)
        @size = size
        @sprite = Square.new(x: x, y: y, z: 1, size: size, color: '#ffbdea')
    end

end