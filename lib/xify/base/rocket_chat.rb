require 'json'
require 'net/https'
require 'time'

module Base
  class RocketChat
    def initialize(config)
      @config = config

      uri = URI.parse config['uri']
      @http = Net::HTTP.new uri.host, uri.port
      @http.use_ssl = true

      working_dir = "#{ENV['HOME']}/.xify/RocketChat"
      Dir.mkdir working_dir rescue Errno::EEXIST
      @auth_file = "#{working_dir}/#{@config['user']}.json"
    end

    def request(method, path, &block)
      login unless @auth_data

      req = Object.const_get("Net::HTTP::#{method.capitalize}").new path,
        'X-User-Id' => @auth_data['userId'],
        'X-Auth-Token' => @auth_data['authToken']

      yield req if block_given?

      res = @http.request req

      case res
      when Net::HTTPUnauthorized
        relogin
        request method, path, &block
      when Net::HTTPSuccess
        # nothing
      else
        raise "Error on #{method.upcase} #{@config['uri']}#{path}: #{res.code} #{res.message}\n#{res.body}"
      end

      res
    end

    private

    def login
      if File.exists? @auth_file
        @auth_data = JSON.parse File.read @auth_file
        return
      end

      req = Net::HTTP::Post.new '/api/v1/login',
        'Content-Type' => 'application/json'
      req.body = {
        username: @config['user'],
        password: @config['pass']
      }.to_json

      res = @http.request req

      raise "Error while authenticating to #{@config['uri']}: #{res.code} #{res.message}\n#{res.body}" unless res.is_a? Net::HTTPSuccess

      @auth_data = JSON.parse(res.body)['data']
      File.write @auth_file, @auth_data.to_json
    end

    def relogin
      File.delete @auth_file
      login
    end
  end
end
