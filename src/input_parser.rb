require_relative 'song'
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
        songs << Song.new(new_song_name)
      end
    end
    f.close
  end

  # search kickass api
  def search_next_song(song)
    puts "Searching song #{song.name}"

    response = HTTParty.get("https://kickass.to/json.php",
      query: {
        q: song.name,
        field: "seeders",
        order: "desc"
      })
    # the api doesn't support category filtering it seems... wrote it ourselves.
    unverified_torrent_results = JSON.parse(response)['list'].select {|result| 
      result['category'] == "Music"
    }


    # only give one torrent now... the first that verifies with the most seeds.
    verified = unverified_torrent_results.find { |json_result|
      verify_torrent(json_result['link'], song)
    }
    if verified
      song.torrents = []
    end 
  end

  def search_google_on_missing(song)
    if (song.torrents.empty?)
      response = HTTParty.get("http://ajax.googleapis.com/ajax/services/search/web",
        query: {
          q: "site:kickass.to #{song.name}",
          v: "1.0"
        })

      parsed = JSON.parse(response)
      binding.pry if !(parsed && parsed['responseData'] && parsed['responseData']['results'])

      song.google_results = parsed['responseData']['results']

      visit_site_on_google(song)
    end
  end

  def verify_torrent(link, song)
    binding.pry if (!HTTParty.get(link))
    n = Nokogiri::HTML(HTTParty.get(link))
   # get the song filename as it appears
    filename = n.css('.torrentFileList .torFileName').select { |file_in_torrent| 
      
          # name has all words that are in the song name
          song.name.split(" ").all? do |word|
            file_in_torrent.text.downcase.include?(word.downcase)
          end 

    }.map(&:text).first
    
    song.file_name_in_torrent = filename
    # return false if not found...
    !!filename
  end

  def visit_site_on_google(song)
    song.google_results.each {|result|
      binding.pry if (!result['url'])
      n=Nokogiri::HTML(HTTParty.get(result['url']))

      number_of_seeds = n.css('.seedBlock').text[-1].to_i
      
      if (number_of_seeds > 0)
        song.torrent_links << {
          seeds: number_of_seeds,
          'torrentLink' => n.css('.downloadButtonGroup a[rel=nofollow]')[0]['href']
        }
      end
    }
  end
end

