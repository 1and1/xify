class Item
  attr_accessor :link, :message, :source, :author, :parent, :parent_link, :time
  def initialize(link:, message:, source:, author: 'Anonymous', parent: nil, parent_link: nil, time: Time.now.iso8601)
    self.author = author
    self.link = link
    self.message = message
    self.parent = parent
    self.parent_link = parent_link
    self.source = source
    self.time = time
  end
end
