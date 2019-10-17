require 'rss'
require 'open-uri'

module Input
  class Rss
    def initialize(config)
      @config = config

      @uri = URI.parse config['uri']

      working_dir = "#{ENV['HOME']}/.xify/Rss"
      Dir.mkdir working_dir rescue Errno::EEXIST
      @latest_file = "#{working_dir}/#{@uri.to_s.gsub(/\W+/, '_')}"

      @latest_time = Time.now
    end

    def updates
      opts = {}
      opts[:first] = :now if @config['trigger']['now']
      Rufus::Scheduler.singleton.repeat @config['trigger']['schedule'], opts do |job|
        job_interval = job.last_time - @latest_time
        @latest_time = job.last_time
        open(@uri) do |rss|
          latest = Time.parse File.read(@latest_file) rescue Time.now - job_interval
          feed = RSS::Parser.parse(rss)
          feed.items
            .select do |item|
              item.pubDate > latest
            end
            .sort_by do |item|
              item.pubDate
            end
            .each do |item|
              yield Xify::Event.new(
                item.dc_creator,
                "*#{item.title}*\n\n#{item.description}",
                link: item.link,
                parent: feed.channel.title,
                parent_link: feed.channel.link,
                time: item.pubDate
              )
              update_latest item
            end
        end
      end
    end

    private

    def update_latest(latest)
      File.write @latest_file, latest.pubDate.to_s
    end
  end
end
