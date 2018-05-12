module Input
  class Pipe
    def initialize(config)
      @author = config['author']
    end

    def updates
      out = ARGF.read.chomp
      yield Event.new @author, out if out && out.length != 0
    end
  end
end
