class Collider

    attr_reader :list

    # create a hash that will recieve all game objects in the scene
    def initialize
        @list = {}
    end

    # add object to corresponding class array in the hash
    def add_object(obj)
        sym = obj.class.to_s.to_sym

        unless @list.has_key?(sym)
            @list[sym] = []
        end

        @list[sym].push(obj)
    end

    # remove all objects from hash
    def remove_all
        @list.each_key do |key|
            @list[key].each do |o|
                if o
                    o.sprite.remove
                    @list[key].delete(o)
                end
            end
            @list.delete(key)
        end
    end

    # compares obj target position with other elements with colliders from groups specified in arr of symbols
    # returns the element that the object is colliding with or nil if there is no collision
    def will_collide_with(obj, arr)
        val = nil
        if obj.target_x
            arr.each do |group|
                @list[group].each do |element|
                    unless element.object_id == obj.object_id
                        if element.center_x == obj.target_x && element.center_y == obj.target_y
                            val = element
                        end
                    end
                end
            end
        end
        val
    end

    # compares obj current position with other elements with colliders from groups specified in arr of symbols
    # returns the element that the object is colliding with or nil if there is no collision
    def is_colliding_with(obj, arr)
        val = nil
        arr.each do |group|
            @list[group].each do |element|
                unless element.object_id == obj.object_id
                    if element.center_x == obj.center_x && element.center_y == obj.center_y
                        val = element
                    end
                end
            end
        end
        val
    end

    # check collision between 2 given objects
    def are_colliding?(obj1, obj2)
        obj1.center_x == obj2.center_x && obj1.center_y == obj2.center_y
    end

    # check if all goals have boxes
    def is_game_over?
        goals_with_boxes = 0
        @list[:Goal].each do |goal|
            @list[:Box].each do |box|
                if are_colliding?(goal, box)
                    goals_with_boxes += 1
                end
            end
        end
        goals_with_boxes == @list[:Goal].count
    end

    alias_method :<<, :add_object
end