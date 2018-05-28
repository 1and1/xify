module Input
  class Shell
    def initialize(config)
      @config = config
    end

    def run
      out = `#{@config['shell']}`.chomp
      yield Xify::Event.new @config['author'], out, parent: @config['shell'] if out && out.length != 0
    end

    def updates(&block)
      return run(&block) unless @config['trigger']

      opts = {}
      opts[:first] = :now if @config['trigger']['now']
      Rufus::Scheduler.singleton.repeat @config['trigger']['schedule'], opts do
        run(&block)
      end
    end
  end
end
