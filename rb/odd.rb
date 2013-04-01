#!/usr/bin/env ruby
#
# Noticed this odd numerical behavior.
#

val=ARGV[0].split(//)
raise "I pity da foo that types in a number that isn't 4 digits." unless val.size == 4

puts "Starting with #{val}"
test=val.join().to_i
count=0
while ((test > 1000) and (count < 20))
  temp=0
  rev=val.reverse.join.to_i
  if rev > test then
    print "#{rev}-#{test}"
    temp=rev-test
  else
    temp=test-rev
    print "#{test}-#{rev}"
  end
    puts "=#{temp}"
  val=temp.to_s.split(//)
  test=val.join().to_i
  count+=1
end

