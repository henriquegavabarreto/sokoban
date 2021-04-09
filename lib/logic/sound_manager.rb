require 'ruby2d'

class SoundManager

    attr_reader :list

    def initialize
        @list = {}
        list[:win] = Sound.new(File.join('assets', 'sounds', 'win.mp3'))
        list[:intro] = Music.new(File.join('assets', 'music', 'intro.wav'), {loop: true})
    end

end