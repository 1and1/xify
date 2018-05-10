require 'yaml'

require 'xify/input/stdin'
require 'xify/output/stdout'
require 'xify/output/rocket_chat'

class Xify
  def self.run(args)
    working_dir = "#{ENV['HOME']}/.xify"
    Dir.mkdir working_dir rescue Errno::EEXIST

    config_file = args.shift || "#{working_dir}/config.yml"
    puts "Loading config from #{config_file}"
    config = YAML::load_file config_file

    config.keys.each do |c|
      config[c].map! do |handler|
        next unless handler['enabled']
        Object.const_get(handler['class']).new(handler)
      end
    end

    puts 'Looking for updates'
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
