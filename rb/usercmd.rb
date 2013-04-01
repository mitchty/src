#!/usr/bin/env ruby
require 'rubygems'

start=Time.now()
runtime=(Random.new.rand(10..20))

file = ARGV[0]
str = "Running for #{runtime} seconds writing to #{file}"

f = File.new(file, File::CREAT|File::TRUNC|File::RDWR, 0644)
f.sync = true
$stdout.sync = true

f.puts str
puts str

begin 
  until (Time.now() >= (start+runtime)) do
    time=Time.now()
    f.puts time
    sleep 1
  end
rescue Interrupt
  f.close
  exit 99
end

puts 'Shutting down.'
f.puts 'Done.'
f.close

exit 0
