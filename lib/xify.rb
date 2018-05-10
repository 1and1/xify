require 'xify/input/stdin'
require 'xify/output/stdout'

class Xify
  def self.run
    puts 'Initializing'
    inputs = [ Stdin.new ]
    outputs = [ Stdout.new ]

    puts 'Looking for updates'
    inputs.each do |i|
      i.updates do |u|
        outputs.each do |o|
          o.process u
        end
      end
    end
  end
end
