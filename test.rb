#!/usr/bin/ruby

require 'stash-api'

puts "Enter username:"
username = STDIN.gets.chomp
puts "Enter passwork:"
password = STDIN.gets.chomp
stash_client = Stash::Client.new(username, password)