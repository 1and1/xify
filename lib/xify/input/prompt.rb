require 'xify/event'

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
            # Stop on CTRL+D
            puts
            break
          end

          if input.length != 1
            yield Event.new @author, input.chomp
          end
        rescue Interrupt
          # Stop on CTRL+C
          puts
          break
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
