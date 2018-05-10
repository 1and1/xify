require 'yaml'

require 'xify/input/stdin'
require 'xify/output/stdout'
require 'xify/output/rocket_chat'

class Xify
  def self.run
    puts 'Loading config'

    config = YAML::load_file "#{ENV['HOME']}/.xify"

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
