class Item
  attr_accessor :title, :message, :source
  def initialize(title:, message:, source:)
    self.title = title
    self.message = message
    self.source = source
  end
end
