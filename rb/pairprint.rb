#!/usr/bin/env ruby
#
# Quick script to get a list of pairs, in this case we just print out to the
# screen
#
require "~/.src/rb/pair"
require 'set'

#
# Need to make the add_if method take a proper proc object
# this is pretty contrived
#
class Set
  def add_if(me)
    notfound = true
    self.each do |x|
      if x == me then
        notfound = false
      end
    end
    self.add(me) if notfound
  end
end

@input = Set.new(ARGV.to_a.sort)
@pairs = Set.new

@input.each do |oval|
  @input.each do |ival|
    next if(oval == ival)
    @pairs.add_if Pair.new(ival, oval)
    @pairs.add_if Pair.new(oval, ival)
  end
end

#
# basic output
#
str = @input.to_a.join(', ')
print "Input \"#{str}\" has #{@pairs.size} unique pairs:\n"
@pairs = @pairs.sort

#
# Cheap, but grab the biggest pair, add 2 to that (, ) and divide the terminal
# columns lines so we know how many pairs to print
#
term_size = %x(/usr/bin/tput cols).to_i
line_len = 0
@pairs.each do |this_pair|
  if line_len == 0 then
    print "#{this_pair}"
    line_len += this_pair.length
  elsif (line_len + this_pair.length + 2) > term_size then
    print "\n#{this_pair}"
    line_len = 0
    line_len += this_pair.length
  else
    print ", #{this_pair}"
    line_len += this_pair.length + 2
  end
end
print "\n"
