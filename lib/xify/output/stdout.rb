class Stdout
  def process(items)
    items.each do |i|
      puts "[#{Time.now.strftime('%FT%T')}] #{i}"
    end
  end
end
