class Shell
  def initialize(config)
    @config = config
  end

  def updates
    out = `#{@config['shell']}`.chomp
    yield Event.new @config['author'], out, parent: @config['shell'] if out && out.length != 0
  end
end
