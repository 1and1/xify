require 'json'
require 'net/https'
require 'time'

class RocketChat
  def initialize(config)
    @channel = config['channel']
    uri = URI.parse config['uri']
    @http = Net::HTTP.new uri.host, uri.port
    @http.use_ssl = true

    @user = config['user']
    @pass = config['pass']

    working_dir = "#{ENV['HOME']}/.xify/RocketChat"
    Dir.mkdir working_dir rescue Errno::EEXIST
    @auth_file = "#{working_dir}/#{@user}.json"
  end

  def login
    if File.exists? @auth_file
      @auth_data = JSON.parse File.read @auth_file
      return
    end

    req = Net::HTTP::Post.new '/api/v1/login',
      'Content-Type' => 'application/json'
    req.body = {
      username: @user,
      password: @pass
    }.to_json

    res = @http.request req

    raise "Error: #{res.code} #{res.message}\n#{res.body}" unless res.is_a? Net::HTTPSuccess

    @auth_data = JSON.parse(res.body)['data']
    File.write @auth_file, @auth_data.to_json
  end

  def reset_auth
    @auth_data = nil
    File.delete @auth_file
  end

  def authenticated_request
    login unless @auth_data

    req = Net::HTTP::Post.new '/api/v1/chat.postMessage',
      'Content-Type' => 'application/json',
      'X-User-Id' => @auth_data['userId'],
      'X-Auth-Token' => @auth_data['authToken']

    yield req

    req
  end

  def process(item)
    res = @http.request(authenticated_request do |req|
      req.body = {
        channel: @channel,
        alias: item.author,
        attachments: [
          {
            author_name: item.source,
            ts: item.time,
            message_link: item.link,
            title: item.parent,
            title_link: item.parent_link,
            text: item.message
          }
        ]
      }.to_json
    end)

    case res
    when Net::HTTPUnauthorized
      reset_auth
      process(item)
    when Net::HTTPSuccess
      # nothing
    else
      $stderr.puts "Error: #{res.code} #{res.message}\n#{res.body}"
    end
  end
end
