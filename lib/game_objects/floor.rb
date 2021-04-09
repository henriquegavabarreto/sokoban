require 'ruby2d'
require_relative './helpers/positioning'

class Floor
    
    include Positioning

    attr_reader :sprite

    def initialize(x, y, size)
        @size = size
        @sprite = Image.new(File.join('assets', 'images', 'floor.png'), x: x, y: y, width: size, height: size)
    end

end