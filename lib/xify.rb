require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'rufus-scheduler'
require 'yaml'

module Xify
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
        require "xify/#{type}/#{handler['class'].underscore}"
        Object.const_get("Xify::#{type.capitalize}::#{handler['class']}").new handler
      end.compact!
    end

    begin
      config['inputs'].each do |i|
        begin
          i.updates do |u|
            config['outputs'].each do |o|
              begin
                o.process u
              rescue => e
                error e
              end
            end
          end
        rescue => e
          error e
        end
      end

      Rufus::Scheduler.singleton.join
    rescue Interrupt
      $stderr.puts "\nExiting."
    end
  end

  def self.debug(str)
    puts str if @verbose
  end

  def self.error(e)
    return $stderr.puts e.message unless @verbose

    $stderr.puts "#{e.backtrace.first}: #{e.message} (#{e.class})", e.backtrace.drop(1).map{|s| "\t#{s}"}
  end
end
