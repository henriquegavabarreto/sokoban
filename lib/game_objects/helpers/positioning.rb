module Positioning

    def position(x, y)
        @sprite.x = x
        @sprite.y = y
    end

    def x
        @sprite.x
    end

    def center_x
        self.x + @size / 2
    end

    def y
        @sprite.y
    end

    def center_y
        self.y + @size / 2
    end
    
end