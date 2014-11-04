require_relative 'input_parser'
require_relative 'torrent_file_saver'
require 'pry'

def mark_line_as_done(line)
  text = File.read(ARGV[0])
  replace = text.gsub(line, "-" + line[1..line.length])
  File.open(ARGV[0], "w") {|file| file.puts replace}
end


parser = InputParser.new(ARGV[0])
saver = TorrentFileSaver.new(parser)
saver.clear_torrents

lines = File.readlines(ARGV[0])
lines.each do |line|
  if line[0] == "+"
    new_song_name = line.split("+")[1].split("\r")[0]
    song = Song.new(new_song_name)
    parser.songs << song

    parser.search_next_song(song)

    parser.search_google_on_missing(song)

    if (song.sorted_torrents.first)
      if (saver.save_to_file(song))
        to_run = "java -cp ./bin Torrenado -f \"#{song.saved_file}\" -s \"#{song.name}\" -u larry -p [randomlygeneratedpassword]"
        puts "Running #{to_run}"
        if (system to_run)
          puts 'Torrent sent to download program'
        end
        mark_line_as_done(line)
      end
    end
  end

end




