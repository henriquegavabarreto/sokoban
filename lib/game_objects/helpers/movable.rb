require_relative './positioning'

class Movable

    include Positioning

    attr_reader :size, :original_position, :target_position, :sprite, :current_direction, :distance_to_travel, :start_x, :start_y, :steps, :position_over_time

    def initialize(sprite, size)
        @size = size
        @sprite = sprite
        @start_x = sprite.x
        @start_y = sprite.y
        @is_moving = false
        @speed = 130
        @current_direction = { x: 1, y: 0 }
        @distance_to_travel = 0
        @total_traveled_distance = 0
        @steps = 0
        @position_over_time = []
        add_to_position_over_time
    end

    def set_target_position
        @target_position = { x: self.x + (@size * @current_direction[:x]), y: self.y + (@size * @current_direction[:y]) }
    end

    def set_original_position
        @original_position = { x: self.x, y: self.y }
    end

    def set_direction(x, y)
        @current_direction = { x: x, y: y }
    end

    def target_x
        @target_position ? self.target_position_center[:x] : nil
    end

    def target_y
        @target_position ? self.target_position_center[:y] : nil
    end

    def is_moving?
        @is_moving
    end

    def target_position_center
        { x: @target_position[:x] + @size / 2, y: @target_position[:y] + @size / 2 }
    end

    def set_destination(x, y)
        # destination is only set if object is still
        return if @distance_to_travel > 0
        @distance_to_travel = @size
        self.set_direction(x, y)
        self.set_target_position
        self.set_original_position
    end

    def cancel_movement
        @distance_to_travel = 0
    end

    # the method below could be applied to move a box
    # moves the character in the facing direction or stops its motion if @target_position is reached
    def move(dt)
        return if @distance_to_travel == 0

        traveled_distance = 0

        unless @current_direction[:x] == 0 then
            traveled_distance = @current_direction[:x] * @speed * dt
        else
            traveled_distance = @current_direction[:y] * @speed * dt
        end

        if @total_traveled_distance + traveled_distance.abs < @distance_to_travel

            @is_moving = true

            unless @current_direction[:x] == 0 then
                @sprite.x += traveled_distance
            else
                @sprite.y += traveled_distance
            end

            @total_traveled_distance += traveled_distance.abs

        else
            self.end_movement
        end
    end

    def end_movement
        self.position(@target_position[:x], @target_position[:y])
        @is_moving = false
        @total_traveled_distance = 0
        @distance_to_travel = 0
        @target_position = nil
    end

    def add_to_position_over_time
        @position_over_time << { x: self.x, y: self.y }
    end

    def slice_position_over_time(n)
        @position_over_time.slice!(n + 1, @position_over_time.count)
    end

    def reset_position_over_time
        slice_position_over_time(0)
    end

end