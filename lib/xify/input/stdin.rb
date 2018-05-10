require 'xify/item'

class Stdin
  def initialize(config)
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
          yield Item.new link: 'http://localhost', message: input, source: 'stdin'
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
