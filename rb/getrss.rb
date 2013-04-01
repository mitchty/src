#!/usr/bin/env ruby
require 'rubygems'
require 'rss'
require 'open-uri'
require 'cgi'

rss_feed = ARGV[0] || exit     # die if nothing given
match_string = ARGV[1] || '.*'
match_string = match_string.split(',')
save_to = ARGV[2] || '/tmp'    # save to /tmp if nothing specified
rss_content = ""
open(rss_feed) do |f|
  rss_content = f.read
end
rss = RSS::Parser.parse(rss_content, false)

puts "Title: #{rss.channel.title}"
puts "RSS URL: #{rss.channel.link}"
puts "Total entries: #{rss.items.size}"

rss.items.each do |item|
  match_string.each do |matchthis| 
    if item.title.to_s =~ /#{matchthis}/ then
    puts "Found link:'#{item.link}'"
    puts "Titled: #{item.title}"
    puts "Published on: #{item.date}"
    puts "Rss description: #{item.description}"
    fname = "#{save_to}/#{item.title}"
    puts "Saving to file: #{fname}\.torrent"
    Dir.chdir(save_to.to_s)
    Kernel.system("/usr/bin/curl -gO -- #{CGI.escapeHTML(item.link)}")
    end
  end
end
