require 'eventmachine'
require 'json'
require 'metybur'
require 'net/https'
require 'time'

require 'xify/base/rocket_chat'

module Input
  class RocketChat < Base::RocketChat
    def updates
      login

      EM.run do
        config = @config
        uri = URI.parse config['uri']
        meteor = Metybur.connect "wss://#{uri.host}:#{uri.port}/websocket"
        meteor.login resume: @auth_data['authToken'] do
          meteor.subscribe 'stream-notify-user', "#{result[:id]}/rooms-changed", false
          messages = meteor.collection 'stream-notify-user'
          messages.on(:changed) do |id, attributes|
             event = attributes[:args].last
             room = event[:name]
             message = event[:lastMessage]

             next if message[:editedAt] || room != config['channel'][1..-1]

             author = message[:u][:name]
             text = message[:msg]
             time = message[:ts][:'$date']
             type = event[:t] == 'p' ? 'group' : 'channel'

             yield Event.new author, text, parent: "##{room}", parent_link: "#{config['uri']}/#{type}/#{room}", time: Time.at(time / 1000)
          end
        end
      end
    end
  end
end
