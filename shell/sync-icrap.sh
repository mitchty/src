#!/usr/bin/env ksh
#-*-mode: shell-mode; coding: utf-8;-*-

osascript <<EOF
if not iTunesRunning() then return

set devices to {"spiceweasel", "Gutenberg"}

tell application "iTunes"
	repeat with a_device in devices
		try
			set src to (some source whose name contains a_device)
			tell src to update
		end try
	end repeat
end tell

to iTunesRunning()
	tell application id "sevs" to return (exists (some process whose name is "iTunes"))
end iTunesRunning
EOF
