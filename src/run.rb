require_relative 'input_parser'
require_relative 'torrent_file_saver'
require 'pry'

parser = InputParser.new(ARGV[0])
saver = TorrentFileSaver.new(parser)
saver.clear_torrents

f = File.open(ARGV[0], "r+")
old_pos = 0
f.each_line do |line|
  if line[0] == "+"
    f.pos = old_pos   # this is the 'rewind'
    new_song_name = line.split("+")[1].split("\r")[0]
    song = Song.new(new_song_name)
    # parser.songs << song

    # parser.search_next_song(song)

    # parser.search_google_on_missing(song)

    if (song.sorted_torrents.first)
      # saver.save_to_file(song)
      to_run = "java -cp ./bin Torrenado -f #{song.saved_file} -s \"#{song.name}\" -u larry -p [randomlygeneratedpassword]"
      puts "Running #{to_run}"
      system to_run

      f.print "-"
      f.pos = f.pos - 1
    end
  end
end

f.close


