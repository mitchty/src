#!/usr/bin/env ruby
#-*-mode: Ruby; coding: utf-8;-*-
require 'time'
RUN_TIME=Time.now

Maid.rules do
  DAY_SECONDS = 60 * 60 * 24
  WEEK = DAY_SECONDS * 7

  # Common to multiple platform(s) stuff.
  def clean_download_dir
  end

  case %x/uname -s/.chomp
  when 'Darwin'
    rule 'Clean old homebrew cache' do
      dir('/Library/Caches/Homebrew/*.tar.*').each do |path|
        trash path if (File.mtime(path) < (RUN_TIME - (DAY_SECONDS * 93)))
      end
    end

    rule 'Old files downloaded while developing/testing' do
      clean_download_dir
    end

    rule 'Clear out stupid Flash crap.' do
      dir('~/Library/Preferences/Macromedia/Flash Player/\#SharedObjects/*').each do |path|
        trash path if (File.mtime(path) < (RUN_TIME - WEEK))
      end
    end
  when 'Linux'
    rule 'Clean Download dir' do
      clean_download_dir
    end
  end
end
