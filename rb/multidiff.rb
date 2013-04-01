#!/usr/bin/env ruby
#
# A diff workalike command that uses set operations to determine common lines between configrations
#
# When I feel more ambitious I will change it to output diff compatible lines, right now
# it is for humans only
#

require 'set'
require 'optparse'

class MyOptions < OptionParser
  attr_accessor :ignoreblanklines, :ignorehashcomments, :ignorebangcomments, :ignorecppcomments
  def initialize(args = ARGV)
    super(args)
    self.ignoreblanklines = false
    self.ignorehashcomments = false
    self.ignorebangcomments = false
    self.ignorecppcomments = false
    self.banner = "Valid options:"
    self.on("-b", "--ignore-blanks", "Don't parse blank lines") do 
        self.ignoreblanklines = true 
    end
    self.on("-a", "--ignore-hash", "Ignore comments beginning with hashes (#)") do
        self.ignorehashcomments = true
    end
    self.on("-s", "--ignore-asterisk", "Ignore comments beginning with asterisks (*)") do
        self.ignorebangcomments = true
    end
    self.on("-c", "--ignore-cpp", "Ignore comments beginning with // (c++ style comments)") do
        self.ignorecppcomments = true
    end
    self.on("-h", "--help", "Display help") do
      puts self
      exit 1
    end
    self.parse!(args)
    self.check
  end
  def check
    #puts foo
  end
end

common, minor_set, unique, reset = '', '', '', ''
case ENV['TERM']
when "xterm" || "dtterm" || "xtermc" || "xterm-color"
#  common = %x(/usr/bin/tput setaf 2) # green fg
#  minor_set = %x(/usr/bin/tput setaf 3) # yellow fg
#  unique = %x(/usr/bin/tput setaf 1) # red fg
#  reset = %x(/usr/bin/tput sgr0) # reset the terminal
  common = ''
  minor_set = ''
  unique = ''
  reset = ''
end
options = MyOptions.new
all_lines = Set.new
common_to_all = Set.new
other_common_sets = Hash.new
file_sets = Hash.new
file_unique_sets = Hash.new

# get all the precious arguments, add them to the @file_sets hash as appropriate
#
args = $*
args.each do |anarg|
  if(File.exists?(anarg)) then
    tmp = File.open(anarg)
    file_sets[anarg] = tmp.readlines
    if(options.ignoreblanklines) then
      file_sets[anarg].delete_if {|x| x =~ %r/^\s*$/}
    end
    if(options.ignorehashcomments) then
      file_sets[anarg].delete_if {|x| x =~ %r/^\s*\#.*$/}
    end
    if(options.ignorebangcomments) then
      file_sets[anarg].delete_if {|x| x =~ %r/^\s*\*.*$/}
    end
    if(options.ignorecppcomments) then
      file_sets[anarg].delete_if {|x| x =~ %r/^\s*\/\/.*$/}
    end
    all_lines.merge(Array[file_sets[anarg]].flatten.to_set)
  end
end

puts "Every line in all input files:"
all_lines.each do |x|
  puts x
end

common_to_all = all_lines
file_sets.values.collect {|x| common_to_all &= x.to_set}

puts "\nLines common to all files:"
common_to_all.each do |x|
  puts common + x
end

all_lines.each do |x|
  tmp = Array.new
  file_sets.each_pair do |key,val|
    (val.to_set.include?(x)) ? tmp.push(key) : nil
  end
  !(tmp.empty?) ? other_common_sets[x] = tmp : nil
end

file_sets.each_pair do |key,val|
  tmp = val.to_set ^ common_to_all
  other_common_sets.each_key do |x|
    tmp = x.to_set ^ tmp
  end
  file_unique_sets[key] = tmp
end

all_other_sets = Array.new
other_common_sets.each_pair do |key,val|
  if(val.size == 1 or file_sets.size == val.size) then
    other_common_sets.delete(key)
    next
  end
  keys = Array.new
  other_common_sets.each_pair do |tmpkey,tmpval|
    keys.push(tmpkey) if(tmpval == val)
  end
  other_common_sets.delete_if {|k,v| (k != key) and (v == val)}
  puts reset + "\nCommon set between: #{val.join(', ')}"
  puts minor_set + keys.join
  all_other_sets.push(keys)
end

file_sets.each_pair do |key,value|
  tmp = all_lines - common_to_all
  other_sets = all_other_sets.flatten.to_a.to_set
  tmp = tmp - other_sets
  tmp = tmp & value.to_set
  next if tmp.empty?
  puts reset + "\nUnique lines for #{key}"
  puts unique + tmp.to_a.flatten.to_s
end
print reset
