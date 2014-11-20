require_relative 'input_parser'
require_relative 'torrent_file_saver'
require 'pry'

def mark_line_as_done(line)
  text = File.read(ARGV[0])
  replace = text.gsub(line, "-" + line[1..line.length])
  File.open(ARGV[0], "w") {|file| file.puts replace}
end

## Get OS to ensure correct folder execution
#x86_64-linux
#x64-mingw32
if (RUBY_PLATFORM == "x86_64-linux")
  puts("Linux")
  os_dir = "./"
  torrent_dir = "torrents/"
elsif (RUBY_PLATFORM == "x64-mingw32")
  puts("Windows")
  os_dir = "C:\\Transmission\\transmission-executables\\transmission\\"
  torrent_dir = "torrents\\"
else
  puts("Other")
  os_dir = "./"
  torrent_dir = "torrents/"
end


parser = InputParser.new()
saver = TorrentFileSaver.new(parser,os_dir+torrent_dir)
saver.clear_torrents

lines = File.readlines(ARGV[0])
lines.each do |line|
  if line[0] == "+"
    new_song_name = line.split("+")[1].split("\n")[0]
  	#puts "Searching song #{new_song_name}"
      
  	song = Song.new(new_song_name)
    parser.songs << song

    parser.json_kickass(song)

    if (song.torrent_links.empty?)
      parser.search_google_on_missing(song)
    end
    
    if (song.sorted_torrents.first && saver.save_to_file(song))
      to_run = "java -cp #{os_dir}bin Torrenado -f \"#{song.saved_file}\" -s \"#{song.name}\" -u larry -p [randomlygeneratedpassword] --silent"
      #system "java -cp C:\\Transmission\\transmission-executables\\transmission\\bin Torrenado -f \"C:\\Transmission\\transmission-executables\\transmission\\torrents\\02 Story Of My Life.mp3.torrent\" -s \"Story of my life\" -u larry -p [randomlygeneratedpassword]"
      puts "Running #{to_run}"
      if (system to_run) 
        puts 'Torrent sent to download program'
      end
      mark_line_as_done(line)
    else
      puts "ERROR ON SONG #{song.name}"
      puts "Looks like there are no torrents found for this song in our sources..."
    end
  end
end