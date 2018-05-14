require 'time'

module Output
  class Stdout
    def initialize(config)
    end

    def process(event)
      puts "[#{event.args[:time].iso8601 || Time.now.iso8601}] #{event.author}:\n#{event.message}"
    end
  end
end
