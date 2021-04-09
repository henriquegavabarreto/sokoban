# Game Timer to keep track of game time and get delta time information
class GameTimer
    # Methods
    #
    # update needs to be called in the game loop to update the timer constantly
    #
    # reset_timer can be called to reset timer_start and timer_delta => can be used to keep track of scene times
    #
    #
    # Getters
    #
    # now gets the current time
    # timer_start gets the time of the start of the timer
    # game_start gets the time of the start of the game - when the GameTimer instance is created
    # delta_time gets the time passed between last and current time
    # timer_delta gets the time since the start / reset of the timer
    # game_delta gets the time since the start of the game - the creating of the GameTimer instance

    attr_reader :now, :delta_time, :fixed_delta_time, :timer_start, :timer_delta, :game_start, :game_delta, :finish_time

    def initialize
        @timer_start = (Time.now.to_f * 1000.0) / 1000
        @game_start = @timer_start
        @last_time = 0
        @delta_time = 0
        @fixed_delta_time = 0
        @timer_delta = 0
        @game_delta = 0
        @finish_time = nil
    end

    # updates time information based on current time and fps
    def update(fps)
        @now = (Time.now.to_f * 1000.0) / 1000
        @delta_time = @now - @last_time
        @fixed_delta_time = @delta_time / perfect_frame_time(fps)
        @timer_delta = @now - @timer_start
        @game_delta = @now - @game_start
        @last_time = (Time.now.to_f * 1000.0) / 1000
    end

    # resets timer start time and finish time
    def reset_timer
        @timer_start = (Time.now.to_f * 1000.0) / 1000
        @timer_delta = 0
        @finish_time = nil
    end

    # set a finish time - when a level is completed
    def set_finish_time
        @finish_time = @now
    end

    # return time elapsed since the set finish time or nil if finish_time is nil
    def time_since_finish
        @finish_time ? @now - @finish_time : nil
    end

private

    def perfect_frame_time(fps)
        1000 / fps
    end
end