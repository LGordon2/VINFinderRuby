require 'open-uri'
require 'nokogiri'

def grab_vin(link)
  doc = Nokogiri::HTML(open(link))
  doc.css("div.itemAttr table:last-child tr").each {|row| row.css("td").each {|node| return node.next_element.content.strip if node.content.include? "VIN" } }
  nil
end

threads = []
vins = []
semaphore = Mutex.new
doc = Nokogiri::HTML(open('http://www.ebay.com/sch/Cars-Trucks-/6001/i.html?&_trksid=p2050890.m1603'))
doc.css('table.rsittlref').each do |listing_table|
  link = listing_table.css('div.ittl a').first[:href]
  threads << Thread.new do 
    retrieved_vin = grab_vin(link) 
    semaphore.synchronize do 
      vins << retrieved_vin
    end
  end
end

threads.each {|t| t.join}
puts vins.compact.inspect
