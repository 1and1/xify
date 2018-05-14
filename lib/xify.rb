require 'rufus-scheduler'
require 'yaml'

require 'xify/input/pipe'
require 'xify/input/prompt'
require 'xify/input/rocket_chat'
require 'xify/input/shell'
require 'xify/output/stdout'
require 'xify/output/rocket_chat'

class Xify
  @verbose = false

  def self.run
    working_dir = "#{ENV['HOME']}/.xify"
    Dir.mkdir working_dir rescue Errno::EEXIST
    config_file = "#{working_dir}/config.yml"
    files = []

    while arg = ARGV.shift do
      case arg
      when '-c', '--config'
        config_file = ARGV.shift
      when '-v', '--verbose'
        @verbose = true
      else
        files << arg
      end
    end

    ARGV.unshift(*files)

    debug "Loading config from #{config_file}"
    config = YAML::load_file config_file

    config.keys.each do |section|
      type = section[0...-1]
      config[section].map! do |handler|
        next unless handler['enabled']
        debug "Setting up #{handler['class']} as #{type}"
        Object.const_get("#{type.capitalize}::#{handler['class']}").new handler
      end.compact!
    end

    config['inputs'].each do |i|
      i.updates do |u|
        config['outputs'].each do |o|
          begin
            o.process u
          rescue => e
            $stderr.puts e.message
          end
        end
      end
    end

    Rufus::Scheduler.singleton.join
  end

  def self.debug(str)
    puts str if @verbose
  end
end
