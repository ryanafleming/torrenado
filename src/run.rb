require_relative 'input_parser'
require_relative 'torrent_file_saver'
require 'pry'

parser = InputParser.new(ARGV[0])

parser.read_file

parser.search_all

parser.search_google_on_missing

saver = TorrentFileSaver.new(parser)
saver.save_all

parser.songs.each {|song|
  to_run = "java -cp ./bin Torrenado -f #{song.saved_file} -s \"#{song.name}\" -u larry -p [randomlygeneratedpassword]"
  puts "Running #{to_run}"
  system to_run
}


