class Event
  attr_accessor :author, :message, :args
  def initialize(author, message, **args)
    self.author = author
    self.message = message
    self.args = args
  end
end
