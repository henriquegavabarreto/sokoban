#!/usr/bin/env ruby
require 'ruby2d'
require_relative 'lib/logic/scene_manager'

scene_manager = SceneManager.new

scene_manager.start

on :key do |event|
  scene_manager.handle_key_press(event)
end

update do
  scene_manager.update
end

Window.show