require_relative 'input_parser'
require 'pry'

# parser = InputParser.new("Music_test.txt")
parser = InputParser.new("Music_test.txt")

parser.read_file

parser.search_all

parser.search_google_on_missing

# show us the seeds!
# puts parser.songs.map {|song| [song.name, song.torrents.first && song.torrents.first['seeds']]}

puts parser.songs.first.torrent_links
