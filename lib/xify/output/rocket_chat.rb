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
  end

  def login
    req = Net::HTTP::Post.new '/api/v1/login',
      'Content-Type' => 'application/json'
    req.body = {
      username: @user,
      password: @pass
    }.to_json

    res = @http.request req

    raise "Error: #{res.code} #{res.message}\n#{res.body}" unless res.is_a? Net::HTTPSuccess

    data = JSON.parse(res.body)['data']
    @user_id = data['userId']
    @auth_token = data['authToken']
  end

  def authenticated_request
    login if @user_id.nil? || @auth_token.nil?

    req = Net::HTTP::Post.new '/api/v1/chat.postMessage',
      'Content-Type' => 'application/json',
      'X-User-Id' => @user_id,
      'X-Auth-Token' => @auth_token

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
      @user_id = @auth_token = nil
      process(item)
    when Net::HTTPSuccess
      # nothing
    else
      $stderr.puts "Error: #{res.code} #{res.message}\n#{res.body}"
    end
  end
end
