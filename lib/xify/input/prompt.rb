module Input
  class Prompt
    def initialize(config)
      @author = config['author']
    end

    def updates
      loop do
        begin
          input = prompt

          unless input
            raise Interrupt
          end

          if input.length != 1
            yield Xify::Event.new @author, input.chomp
          end
        rescue Interrupt
          raise
        end
      end
    end

    private

    def prompt
      print '> '

      gets
    end
  end
end
