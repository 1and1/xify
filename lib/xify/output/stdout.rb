require 'time'

class Stdout
  def initialize(config)
  end

  def process(item)
    puts "[#{item.time}] #{item.message}"
  end
end
