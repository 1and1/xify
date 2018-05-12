require 'json'
require 'net/https'
require 'time'

require 'xify/base/rocket_chat'

module Output
  class RocketChat < Base::RocketChat
    def process(event)
      request :post, '/api/v1/chat.postMessage' do |req|
        req['Content-Type'] = 'application/json'
        req.body = {
          channel: @config['channel'],
          alias: event.author,
          attachments: [
            {
              title: event.args[:parent],
              title_link: event.args[:parent_link],
              text: event.args[:link] ? "#{event.message.chomp} ([more](#{event.args[:link]}))" : event.message.chomp
            }
          ]
        }.to_json
      end
    end
  end
end
