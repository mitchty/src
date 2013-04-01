#!/usr/bin/env ruby
#
# Nuke caches on osx, frees up things that don't need to stay around long and just
# waste inodes.
#
#$HOME/Library/Preferences/Macromedia/Flash Player/#SharedObjects
#$HOME/Library/Caches
#dscacheutil -flushcache
#find $HOME/Library/Logs/CrashReporter -type f -mtime +7 -delete

#
# Add a launchd entry for 6 am in the morning to purge this crap
#
if ARGV[0] == "init" then
  puts "Adding launchctl entry for cacheclean script."
launchctl_plist=<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
      <string>com.mitch.cacheclean</string>
    <key>ProgramArguments</key>
      <array>
        <string>/Users/mitch/src/rb/cacheclean.rb</string>
      </array>
    <key>StandardErrorPath</key>
      <string>/dev/null</string>
    <key>StandardOutPath</key>
      <string>/dev/null</string>
    <key>StartCalendarInterval</key>
      <dict>
        <key>Hour</key>
          <integer>6</integer>
        <key>Minute</key>
          <integer>0</integer>
     </dict>
    <key>RunAtLoad</key>
      <true/>
  </dict>
</plist>
EOF
  output = File.new(File.expand_path("~/.com.mitch.cacheclean.plist"), File::CREAT|File::WRONLY|File::TRUNC)
  output.write(launchctl_plist)
  output.close

  #
  # Just in case remove any old entry and we will load that
  #
  %x(launchctl remove com.mitch.cacheclean)
  %x(launchctl load ~/.com.mitch.cacheclean.plist)
  exit 1
end

require 'fileutils'

module Enumerable
  def any?
    self.each do |item|
      return true if yield(item)
    end
    return false
  end
  def all?
    self.each do |item|
      return true unless yield(item)
    end
    return false
  end
end

ENV["PATH"]="/bin:/usr/bin:/sbin:/usr/sbin"
too_old = 7                    # age in days
too_old_sec = too_old*24*60*60 # d*h*m*s

print "Flushing Directory Service cache..."
%x(dscacheutil -flushcache)
puts $? ? "succeeded." : "had an error <#{$?}>."

user_name = ENV["USER"]
user_home = ENV["HOME"]
user_library = "#{user_home}/Library"
keep_dirs_clean = ["#{user_home}/Downloads",
                   "#{user_home}/.Trash",
                   "#{user_library}/Caches"
                  ]
cache_dirs = ["#{user_library}/Preferences/Macromedia/Flash\\ Player/\\#SharedObjects",
              "#{user_library}/Preferences/Macromedia/Flash\\ Player/macromedia.com/support/flashplayer/sys",
             ]
ignore_entries = [".", "..", ".fseventsd", ".DS_Store"]

cache_dirs.each do |dir|
  puts "Removing old caches in #{dir}"
  %x(rm -Rfv #{dir}/*)
end

puts "Cleaning out old crash logs."
%x(find #{user_library}/Logs/CrashReporter -type f -mtime +#{too_old} -delete)

keep_dirs_clean.each do |thisdir|
  puts "Cleaning out old stuff in #{thisdir}."
  Dir.entries(thisdir).each do |candidate|
    candidate="#{thisdir}\/#{candidate}"
    next if (ignore_entries.any?{|x| x == candidate})
    FileUtils.rm_rf candidate if ((Time.now.to_i - File.stat(candidate).mtime.to_i) > too_old_sec)
  end
end

puts "Cleaning out old stuff for user #{user_name} in /tmp."
%x(find /tmp -type f -mtime +#{too_old} -user #{user_name} -delete)

exit
