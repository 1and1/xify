class Stdin
  def updates
    loop do
      begin
        input = prompt

        unless input
          # Stop on CTRL+D
          puts
          break
        end

        yield [ input ] if input.length != 1
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
