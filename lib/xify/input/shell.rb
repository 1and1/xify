module Input
  class Shell
    def initialize(config)
      @config = config
    end

    def run
      out = `#{@config['shell']}`.chomp
      yield Event.new @config['author'], out, parent: @config['shell'] if out && out.length != 0
    end

    def updates(&block)
      return run(&block) unless @config['schedule']

      Rufus::Scheduler.singleton.repeat @config['schedule'] do
        run(&block)
      end
    end
  end
end
