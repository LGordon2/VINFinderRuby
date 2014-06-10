#Author: Lewis Gordon

require 'open-uri'
require 'nokogiri'
require 'ruby-progressbar'
require 'csv'
require 'thread/pool'

require File.expand_path('../lib/thread_wait_finished', __FILE__)

def grab_vin(link)
  doc = Nokogiri::HTML(open(link))
  doc.css("div.itemAttr table:last-child tr").each {|row| row.css("td").each {|node| return node.next_element.content.strip if node.content.include? "VIN" } }
  nil
end

# Initialize some variables
vins = []
links = []
pool = Thread.pool(30)
semaphore = Mutex.new
csv_filename = "vins/VINs_#{Time.now.to_i}.csv"

# Grab the vehicle count from the first page.
doc = Nokogiri::HTML(open(URI::HTTP.build([nil,'www.ebay.com',nil,'/sch/Cars-Trucks-/6001/i.html',nil,nil])))
vehicle_count = doc.css('div#cbrt div.clt h1.rsHdr span.rcnt').first.content.gsub(',','').to_i
puts "Searching the first 10000 vehicles of #{vehicle_count}."
vehicle_count = 10000 if vehicle_count > 10000
page_count = vehicle_count/50-1
puts "Searching on #{page_count} pages."
puts 'Finding all vehicle links...'

# Grabbing the individual vehicle links.
p = ProgressBar.create(total: page_count, :format => '%a %B %p%% %t')
page_count.times do |num|
  pool.process do
    doc = Nokogiri::HTML(open(URI::HTTP.build([nil,'www.ebay.com',nil,'/sch/Cars-Trucks-/6001/i.html',"_pgn=#{num+1}",nil])))
    listings = doc.css('table.rsittlref')
    listings.each do |listing_table|
      found_link = listing_table.css('div.ittl a')
      links << found_link.first[:href]
    end
    p.increment
  end
end

pool.wait_until_finished

# Finding the VIN in each link.
puts 'Finding all VINs...'
p = ProgressBar.create(total: links.length, :format => '%a %B %p%% %t')
links.each do |link|
  pool.process do 
    retrieved_vin = grab_vin(link) 
    semaphore.synchronize do 
      vins << retrieved_vin
      p.increment
    end
  end
end

pool.wait_until_finished

# Outputting final results and writing to csv.
vins = vins.compact
puts "#{vins.length} VINs retrieved. Writing to [#{csv_filename}]"
CSV.open(csv_filename,'wb') do |csv|
  vins.each do |vin|
    csv << [vin]
  end
end
