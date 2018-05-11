require 'time'

class Stdout
  def initialize(config)
  end

  def process(event)
    puts "[#{event.args[:time] || Time.now.iso8601}] #{event.author}: #{event.message}"
  end
end
