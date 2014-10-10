class InputParser
  require 'httparty'
  require 'nokogiri'
  attr_accessor :songs, :in_file, :out_file

      #   response = HTTParty.get("http://fenopy.se/module/search/api.php",
      # query: {
      #   keyword: song.name,
      #   sort: "relevancy",
      #   format: "json",
      #   limit: "60",
      #   category: "1"
      # })

  def initialize(in_file, out_file=nil)
    self.in_file = in_file
    self.out_file = out_file
    self.songs = []
  end

  def read_file
    f = File.open(in_file, "r")
    f.each_line do |line|
      if line[0] == "+"
        new_song_name = line.split("+")[1].split("\r")[0]
        songs << Struct.new(:name, :torrents, :google_results, 
          #ones found by google
          :torrent_links).new(new_song_name, nil, nil, [])
      end
    end
    f.close
  end

  def search_all
    songs.each do |song|
      search_next_song(song)
    end
  end

  # search kickass api
  def search_next_song(song)
    puts "Searching song #{song.name}"

    response = HTTParty.get("https://kickass.to/json.php",
      query: {
        q: song.name,
        field: "seeders",
        order: "desc",
        page: "1",
      })
    song.torrents= JSON.parse(response)['list']

  end

  def search_google_on_missing
    
    songs.each do |song|
      if (song.torrents.empty?)
        response = HTTParty.get("http://ajax.googleapis.com/ajax/services/search/web",
          query: {
            q: "site:kickass.to #{song.name}",
            v: "1.0"
          })

        song.google_results = JSON.parse(response)['responseData']['results']

        visit_site_on_google(song)

      end
    end

  end

  def visit_site_on_google(song)
    song.google_results.each {|result|

      n=Nokogiri::HTML(HTTParty.get(result['url']))

      number_of_seeds = n.css('.seedBlock').text[-1].to_i
      
      if (number_of_seeds > 0)

        # get the song filename as it appears
        filename = n.css('.torrentFileList .torFileName').select { |file_in_torrent| 
          
              # name has all words
              song.name.split(" ").all? do |word|
                file_in_torrent.text.downcase.include?(word.downcase)
              end 

        }.map(&:text).first

        if (filename)
          song.torrent_links << {
            seeds: number_of_seeds,
            song_title_on_page: filename,
            url: n.css('.downloadButtonGroup a[rel=nofollow]')[0]['href']
          }
        end
      end
    }
  end
end

