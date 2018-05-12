require 'yaml'

require 'xify/input/pipe'
require 'xify/input/prompt'
require 'xify/input/shell'
require 'xify/output/stdout'
require 'xify/output/rocket_chat'

class Xify
  def self.run(args)
    working_dir = "#{ENV['HOME']}/.xify"
    Dir.mkdir working_dir rescue Errno::EEXIST

    config_file = "#{working_dir}/config.yml"
    if args.first == '-c'
      args.shift
      config_file = args.shift
    end

    puts "Loading config from #{config_file}"
    config = YAML::load_file config_file

    config.keys.each do |section|
      ns = section[0...-1].capitalize
      config[section].map! do |handler|
        next unless handler['enabled']
        Object.const_get("#{ns}::#{handler['class']}").new handler
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
  end
end
