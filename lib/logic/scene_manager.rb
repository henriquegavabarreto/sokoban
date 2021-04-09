require 'ruby2d'
require_relative 'game_timer'
require_relative 'collider'
require_relative 'level_manager'
require_relative 'sound_manager'
require_relative '../game_objects/box'

# this class is responsible for the functions inside update
class SceneManager
    
    def initialize
        # always starts the game at intro
        @scene = 'intro'
        @showing_menu = false
        @shortcut_options = []
        @margin = 10
        # holds objects for a particular scene
        @scene_objects = {}
        # temporary objects holds transition scene texts
        # while the transition is happening the next level are being loaded in scene objects
        @temporary_objects = {}
        # creates game and scene timer
        @timer = GameTimer.new
        # creates a collider to provide collider funcionalities to game objects
        @collider = Collider.new
        # creates level manager to create levels from files
        @level_manager = LevelManager.new
        # sound manager holds all sounds and music
        @sound_manager = SoundManager.new
        @top_bar_height = 27 + (@margin * 2)
        @bottom_bar_height = 27 + (@margin * 2)
        # could use cell size to determine width of scene
        # cell_size = 40
        Window.set({
            title: 'sokowho?',
            background: 'black',
            width: @level_manager.max_cell_width * @level_manager.cell_size,
            height: (@level_manager.max_cell_height * @level_manager.cell_size) + @top_bar_height + @bottom_bar_height,
            resizable: true
          })
        draw_shortcut_options
    end

    # loads specific scene
    def load(scene)
        @scene = scene
        start
    end

    # starts loaded scene - executed 1 time
    def start
        # start a timer on scene load
        @timer.reset_timer
        case @scene
        when 'intro'
            start_intro
        when 'level'
            start_level
        when 'transition'
            start_transition
        when 'credits'
            start_credits
        end
    end

    # update goes inside the update function - executed every frame
    def update
        @timer.update(Window.fps)
        case @scene
        when 'intro'
            update_intro
        when 'level'
            update_level
        when 'transition'
            update_transition
        when 'credits'
            update_credits
        end
    end

    # handles key presses depending on current scene
    def handle_key_press(key)
        case @scene
        when 'intro'
            handle_intro_key_press(key)
        when 'level'
            handle_level_key_press(key)
        when 'transition'
        when 'credits'
        end
    end

    #################################################
    #                    Intro                      #
    #################################################
    ### Start Intro ###
    def start_intro
        clear_all
        @level_manager.reset_level_index
        @scene_objects[:title] = Text.new('sokowho?'.upcase, {x: 110, y: -50, size: 25, font: 'assets/fonts/PressStart2P.ttf'})
        @scene_objects[:press_return] = Text.new('press return'.upcase, {x: 105, y: 160, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        align_text_center(@scene_objects[:title])
        align_text_center(@scene_objects[:press_return])
        @centered_positions = get_centered_positions([@scene_objects[:title], @scene_objects[:press_return]], 5)
        @scene_objects[:press_return].y = @centered_positions[1][:y]
        @scene_objects[:press_return].remove
        @sound_manager.list[:intro].play
    end

    ### Update Intro ###
    def update_intro
        speed = 2
        if @scene_objects[:title].y < @centered_positions[0][:y]
            @scene_objects[:title].y += speed
        end
        # is there a better solution for this to be called just one time inside update?
        if @scene_objects[:title].y == @centered_positions[0][:y].floor - speed
            @scene_objects[:press_return].add
        end
    end

    ### Intro Key press ###
    def handle_intro_key_press(event)
        return unless event.type == :down
        key = event.key
        valid_keys = ['return', 'q']
        return unless valid_keys.include?(key)
        if @timer.timer_delta > 3.5
            case key
            when'q'
                Window.close
            when 'return'
                @sound_manager.list[:intro].stop
                load('transition')
            end
        end
        
    end

    #################################################
    #                  Transition                   #
    #################################################
    ### Start Transition ###
    def start_transition
        clear_all
        # if there are no levels to load, show credits
        if @level_manager.no_more_levels
            load('credits')
        else
            # draw top and bottom display text
            draw_top_display
            draw_bottom_display
            # draw transition card with temporary text
            @temporary_objects[:foreground] = Rectangle.new(x: 0, y: 0, z: 5, width: Window.width, height: Window.height, color: 'black')
            @temporary_objects[:title] = Text.new('', {x: 110, y: 140, z: 6, size: 20, font: 'assets/fonts/PressStart2P.ttf'})
            # load level
            @level_manager.load_level(@collider, 0, @top_bar_height)
            @temporary_objects[:title].text = @level_manager.level_title.upcase
            # split transition text if it is bigger than the screen
            if @temporary_objects[:title].width > Window.width - (@margin * 2)
                adjust_transition_text
            else 
                @centered_positions = get_centered_positions([@temporary_objects[:title]])
                @temporary_objects[:title].x = @centered_positions[0][:x]
                @temporary_objects[:title].y = @centered_positions[0][:y]
            end

            # Alter text from top bar
            @scene_objects[:top_display_title].text = @level_manager.level_title.upcase
            max_title_width = @scene_objects[:top_display_moves].x - @margin * 2
            # another solution is to create a type of mask and move the title from time to time
            if @scene_objects[:top_display_title].width > max_title_width
                index = (max_title_width / 15) - 3
                @scene_objects[:top_display_title].text = @scene_objects[:top_display_title].text.slice(0..index) + '...'
            end
        end
    end

    ### Update Transition ###
    def update_transition
        if @timer.timer_delta > 2.5
            load('level')
        end
    end

    ### Transition Key press ###
    # def handle_transition_key_press(key)
    # end

    #################################################
    #                    Level                      #
    #################################################
    ### Start Level ###
    def start_level
        # clear transition layer
        clear_temporary
    end

    ### Update Level ###
    def update_level
        # update objects in @collider
        moves = @collider.list[:Player][0].steps
        # move player
        @collider.list[:Player][0].move(@timer.delta_time)
        # move each of the boxes
        @collider.list[:Box].each do |box|
            box.move(@timer.delta_time)
            if @collider.is_colliding_with(box, [:Goal])
                box.change_sprite('on goal')
            else
                box.change_sprite('regular')
            end
        end

        # player just finished moving! - update top bar steps and pushes and add to position over time
        if @collider.list[:Player][0].steps != moves
            update_pushes_and_steps_text
            # add to position over time
            @collider.list[:Player][0].add_to_position_over_time
            @collider.list[:Box].each do |box|
                box.add_to_position_over_time
            end
        end

        # level is completed - executed only once
        if @collider.is_game_over? && !@timer.finish_time
            @timer.set_finish_time
            @sound_manager.list[:win].play
        end

        # action to be performed 2 seconds after level finishes
        if @timer.finish_time
            if @timer.time_since_finish > 2
                Box.reset_pushes
                load('transition')
            end
        end
    end

    ### Level Key press ###
    def handle_level_key_press(event)
        key = event.key
        valid_moves = ['i', 'j', 'k', 'l']
        player = @collider.list[:Player][0]
        return if !player || @collider.is_game_over?
        # checks if player and box will move
        if player.distance_to_travel <= 0 && valid_moves.include?(key) && !@showing_menu
            player.set_destination_with_key(key)
            obj = @collider.will_collide_with(player, [:Wall, :Box])
            case obj.class.to_s
            when 'Box'
                obj.set_destination(player.current_direction[:x], player.current_direction[:y])
                obj2 = @collider.will_collide_with(obj, [:Wall, :Box])
                if obj2.class.to_s == 'Box' || obj2.class.to_s == 'Wall'
                    player.cancel_movement
                    obj.cancel_movement
                else
                    # player is moving. position over time should be permanently changed for each of the movable objects
                    if @collider.list[:Player][0].position_over_time.count > @collider.list[:Player][0].steps + 1
                        @collider.list[:Player][0].slice_position_over_time(@collider.list[:Player][0].steps)
                        @collider.list[:Box].each do |box|
                            box.slice_position_over_time(@collider.list[:Player][0].steps)
                        end
                    end
                end
            when 'Wall'
                player.cancel_movement
            else
                # player is moving. position over time should be permanently changed for each of the movable objects
                if @collider.list[:Player][0].position_over_time.count > @collider.list[:Player][0].steps + 1
                    @collider.list[:Player][0].slice_position_over_time(@collider.list[:Player][0].steps)
                    @collider.list[:Box].each do |box|
                        box.slice_position_over_time(@collider.list[:Player][0].steps)
                    end
                end
            end
        end

        # move player and boxes to start position - reset steps and pushes
        if key == 'r' && event.type == :up
            player.position(player.start_x, player.start_y)
            player.reset_position_over_time
            @collider.list[:Box].each do |box|
                box.position(box.start_x, box.start_y)
                box.reset_position_over_time
            end
            player.reset_steps
            Box.reset_pushes

            update_pushes_and_steps_text
        end

        # UNDO
        if key == 'u' && event.type == :down
            # undo only if there is at least one movement
            if @collider.list[:Player][0].steps > 0
                # remove step and update player position
                @collider.list[:Player][0].remove_step
                step = @collider.list[:Player][0].steps
                @collider.list[:Player][0].position(@collider.list[:Player][0].position_over_time[step][:x], @collider.list[:Player][0].position_over_time[step][:y])
                
                @collider.list[:Box].each do |box|
                    # if the box moved, update its position and remove a push
                    if box.x != box.position_over_time[step][:x] || box.y != box.position_over_time[step][:y]
                        Box.remove_push
                        box.position(box.position_over_time[step][:x], box.position_over_time[step][:y])
                    end
                end
                # update text on screen
                update_pushes_and_steps_text
            end
        end

        # REDO
        if key == 'y' && event.type == :down
            # redo only applies if there is a position to go to
            if @collider.list[:Player][0].position_over_time[@collider.list[:Player][0].steps + 1]
                # add the step
                @collider.list[:Player][0].add_step
                step = @collider.list[:Player][0].steps
                # change player position
                @collider.list[:Player][0].position(@collider.list[:Player][0].position_over_time[step][:x], @collider.list[:Player][0].position_over_time[step][:y])
                # check if any of the boxes position need to be updated
                @collider.list[:Box].each do |box|
                    # if the box moved, update its position and add a push
                    if box.x != box.position_over_time[step][:x] || box.y != box.position_over_time[step][:y]
                        Box.add_push
                        box.position(box.position_over_time[step][:x], box.position_over_time[step][:y])
                    end
                end
                # update text on screen
                update_pushes_and_steps_text
            end
        end

        if key == 'q' && event.type == :down
            load('intro')
        end

        # show menu
        if key == 'tab' && event.type == :down && !@collider.is_game_over?
            show_shortcut_options
        end

        # hide menu
        if key == 'tab' && event.type == :up
            hide_shortcut_options
        end
    end

    #################################################
    #                    Credits                    #
    #################################################
    ### Start Credits ###
    def start_credits
        @scene_objects[:title] = Text.new('thank you'.upcase, {x: 110, y: -50, size: 20, font: 'assets/fonts/PressStart2P.ttf'})
        align_text_center(@scene_objects[:title])
        @scene_objects[:title2] = Text.new('for playing!'.upcase, {x: 110, y: -50, size: 20, font: 'assets/fonts/PressStart2P.ttf'})
        align_text_center(@scene_objects[:title2])

        @centered_positions = get_centered_positions([@scene_objects[:title], @scene_objects[:title2]], 5)
        group_height = group_height([@scene_objects[:title], @scene_objects[:title2]], 5)
        @scene_objects[:title].y = @centered_positions[0][:y] - @centered_positions[0][:y] - group_height
        @scene_objects[:title2].y = @centered_positions[1][:y] - @centered_positions[0][:y] - group_height
    end

    ### Update Credits###
    def update_credits
        if @scene_objects[:title].y < @centered_positions[0][:y]
            @scene_objects[:title].y += 1
            @scene_objects[:title2].y += 1
        end

        if @timer.timer_delta > 10
            @level_manager.reset_level_index
            load('intro')
        end
    end

    ### Credits Key press ###
    # def handle_credits_key_press(key)
    # end

    #################################################
    #                 HELPER METHODS                #
    #################################################
    # aligns a given text horizontally
    def align_text_center(text_object)
        text_object.x = (Window.width - text_object.width) / 2
    end

    # expects array of text objects and spacing between lines in pixels
    # returns array of hashes with x and y for each of the elements of array
    # with these y positions, we can center the text objects vertically
    def get_centered_positions(arr, spacing = 0)
        centered_positions = []

        first_y = (Window.height - (group_height(arr, spacing))) / 2

        arr.each_index do |i|
            x = (Window.width - arr[i].width) / 2
            if i == 0
                centered_positions << {x: x, y: first_y}
            else
                y = centered_positions[i - 1][:y] + arr[i - 1].height + spacing
                centered_positions << {x: x, y: y}
            end
        end

        centered_positions
    end

    # gets the hight of a group of text
    def group_height(arr, spacing)

        elements_height_sum = 0

        arr.each do |el|
            elements_height_sum += el.height
        end

        elements_height_sum + ((arr.count - 1) * spacing)
    end

    # updates top display text
    def update_pushes_and_steps_text
        @scene_objects[:top_display_moves_number].text = @collider.list[:Player][0].steps
        @scene_objects[:top_display_pushes_number].text = Box.total_pushes
    end

    def draw_top_display
        # create text from right to left
        # each digit is approx. 15 px
        @scene_objects[:top_display_pushes_number] = Text.new('0', {x: Window.width - (@margin / 2) - 45, y: @margin, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @scene_objects[:top_display_pushes] = Text.new('pushes:'.upcase, {x: @scene_objects[:top_display_pushes_number].x - (@margin / 4) - 105, y: @margin, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @scene_objects[:top_display_moves_number] = Text.new('0', {x: @scene_objects[:top_display_pushes].x - @margin - 45, y: @margin, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @scene_objects[:top_display_moves] = Text.new('moves:'.upcase, {x: @scene_objects[:top_display_moves_number].x - (@margin / 4) - 90, y: @margin, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @scene_objects[:top_display_title] = Text.new('Temporary title'.upcase, {x: @margin, y: @margin, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
    end

    def draw_shortcut_options

        @shortcut_options_background = Rectangle.new(x: 0, y: 0, z: 19, width: Window.width, height: Window.height, color: 'black')

        @shortcut_options << Text.new("shortcuts".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @shortcut_options << Text.new("'r' - reset".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @shortcut_options << Text.new("'u' - undo".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @shortcut_options << Text.new("'y' - redo".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @shortcut_options << Text.new("'ijkl' - walk".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})
        @shortcut_options << Text.new("'q' - quit".upcase, {x: 0, y: 0, z: 20, size: 15, font: 'assets/fonts/PressStart2P.ttf'})

        positions = get_centered_positions(@shortcut_options, 10)

        @shortcut_options.each_index do |i|
            align_text_center(@shortcut_options[i])
            @shortcut_options[i].y = positions[i][:y]
            # extra margin for the title
            if i == 0
                @shortcut_options[i].y = positions[i][:y] - 20
            else
                @shortcut_options[i].y = positions[i][:y]
            end
        end

        hide_shortcut_options
    end

    def show_shortcut_options
        @shortcut_options.each do |text|
            text.add
        end
        @shortcut_options_background.add
        @showing_menu = true
    end

    def hide_shortcut_options
        @shortcut_options.each do |text|
            text.remove
        end
        @shortcut_options_background.remove
        @showing_menu = false
    end

    def clear_shortcut_options
        hide_shortcut_options
        @shortcut_options.clear
        @shortcut_options_background = nil
    end

    def draw_bottom_display
        @scene_objects[:bottom_display] = Text.new("hold 'tab' to show options".upcase, {x: Window.width, y: Window.height - 27 / 2 - @margin, size: 20, font: 'assets/fonts/PressStart2P.ttf'})
        align_text_center(@scene_objects[:bottom_display])
    end

    # transforms a long title text in smaller segments to be displayed at the center of the transition screen
    def adjust_transition_text
        if @temporary_objects[:title].width > Window.width - (@margin * 2)
            length_per_char = @temporary_objects[:title].width / @temporary_objects[:title].text.length
            split_title = @temporary_objects[:title].text.split(' ')

            remove_from_temporary(:title)
            title_parts = []
            grouped_text = []
            grouped_text_length = 0
            split_title.each_index do |i|
                grouped_text_length += (split_title[i].length + 1) * length_per_char
                if grouped_text_length > Window.width - (@margin * 2)
                    if i < split_title.length - 1
                        text = grouped_text.join(' ').rstrip
                        sym = "divided_text_#{i}".to_sym
                        # make a new text object
                        @temporary_objects[sym] = Text.new(text, {x: 0, y: 0, size: 20, z: 6, font: 'assets/fonts/PressStart2P.ttf'})
                        
                        title_parts << @temporary_objects[sym]

                        grouped_text = []
                        grouped_text << split_title[i]
                        grouped_text_length = (split_title[i].length + 1) * length_per_char
                    else
                        text = grouped_text.join(' ').rstrip
                        sym = "divided_text_#{i}".to_sym
                        sym2 = "divided_text_#{i + 1}".to_sym

                        # make a new text object with grouped_text
                        @temporary_objects[sym] = Text.new(text, {x: 0, y: 0, size: 20, z: 6, font: 'assets/fonts/PressStart2P.ttf'})
                        # make a new text object with split_title[i]
                        @temporary_objects[sym2] = Text.new(split_title[i], {x: 0, y: 0, size: 20, z: 6, font: 'assets/fonts/PressStart2P.ttf'})

                        title_parts << @temporary_objects[sym]
                        title_parts << @temporary_objects[sym2]
                    end
                else
                    if i < split_title.length - 1
                        grouped_text << split_title[i]
                    else
                        grouped_text << split_title[i]
                        text = grouped_text.join(' ').rstrip
                        sym = "divided_text_#{i}".to_sym
                        # make a new text object with grouped_text
                        @temporary_objects[sym] = Text.new(text, {x: 0, y: 0, size: 20, z: 6, font: 'assets/fonts/PressStart2P.ttf'})
                        title_parts << @temporary_objects[sym]
                    end
                end
            end

            positions = get_centered_positions(title_parts, 5)
            title_parts.each_index do |i|
                title_parts[i].x = positions[i][:x]
                title_parts[i].y = positions[i][:y]
            end
        end
    end

    # clear all objects and window
    def clear_all
        clear_temporary
        clear_objects
        Window.clear
    end

    # clear scene objects only
    def clear_objects
        @scene_objects.each_key do |key|
            @scene_objects[key].remove
            @scene_objects.delete(key)
        end
        @collider.remove_all
    end

    # clear temporary objects only
    def clear_temporary
        @temporary_objects.each_key do |key|
            @temporary_objects[key].remove
            @temporary_objects.delete(key)
        end
    end

    def remove_from_temporary(key)
        @temporary_objects[key].remove
        @temporary_objects.delete(key)
    end
end