#!/usr/bin/env ruby
#
# Meh, because I do this too often.

require 'digest/sha1'
require 'fileutils'

dir = ARGV[0]

unless ARGV[0]
  puts "Specify a directory as the only argument foo"
  exit 1
end

unless File.directory? dir
  puts "#{dir} isn't a directory foo"
  exit 1
end

# so {jpg,jpeg}'s get renamed to sha1.jpg all.
Dir.chdir dir
Dir.glob('*.jp*g').each do |file|
  sha1 = Digest::SHA1.hexdigest(File.open(file).read)
  sha1name = sha1 + '.jpg'
  FileUtils.mv(file, sha1name, :verbose => true) unless sha1name == file
end

Dir.glob('*.png').each do |file|
  sha1 = Digest::SHA1.hexdigest(File.open(file).read)
  sha1name = sha1 + '.png'
  FileUtils.mv(file, sha1 + '.png', :verbose => true) unless sha1name == file
end
