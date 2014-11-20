require_relative 'song'
class InputParser
  require 'httparty'
  require 'nokogiri'
  require 'pry'
    # => Methods and attributes no longer required
  attr_accessor :songs#, :in_file, :out_file

      #   response = HTTParty.get("http://fenopy.se/module/search/api.php",
      # query: {
      #   keyword: song.name,
      #   sort: "relevancy",
      #   format: "json",
      #   limit: "60",
      #   category: "1"
      # })

  def initialize()
  #  self.in_file = in_file
  #  self.out_file = out_file
    self.songs = []
  end

  # search kickass api
  def json_kickass(song)


    #example https://kickass.to/json.php?q=katy%20perry
    response = HTTParty.get("https://kickass.to/json.php",
      query: {
        q: song.name,
        field: "seeders",
        order: "desc"
      })

    # the api doesn't support category filtering it seems... wrote it ourselves.
    # filter by category
    unverified_torrent_results = JSON.parse(response)['list'].select {|result| 
      result['category'] == "Music"
    }

    # only give one torrent now... 
    # the first that verifies with the most seeds.
    # if none are valid, return nil
    verified = unverified_torrent_results.find { |json_result|
      verify_torrent(json_result['link'], song)
    }
    if verified
      song.torrents = [ verified["torrentLink"] ]
    end 
    
  end

  def search_google_on_missing(song)
    
    response = HTTParty.get("http://ajax.googleapis.com/ajax/services/search/web",
      query: {
        q: "site:kickass.to #{song.name}",
        v: "1.0"
      })

    song.google_results = JSON.parse(response)['responseData']['results']

    visit_site_on_google(song)

    
    rescue Exception => ex
      puts "ERROR ON SONG #{song.name}"
      puts "Bad response from google api"
      puts parsed.inspect
      puts ex.message
      puts ex.backtrace.join("\n")
  end

  def verify_torrent(link, song)
   n = Nokogiri::HTML(HTTParty.get(link))
   # get the song filename as it appears
   filename = n.css('.torrentFileList .torFileName').map(&:text).first
   #filename = n.css('.torrentFileList .torFileName').select { |file_in_torrent| 
   #   
   #       # name has all words that are in the song name
   #       song.name.split(" ").all? do |word|
   #         file_in_torrent.text.downcase.include?(word.downcase)
   #       end
   #}.map(&:text).first

    # <td class="torFileIcon"><span class="torType musicType"></span></td>
    #n.css("span[class*='torType']")[0]
    #orrr

    #<span id="cat_9413652"><strong><a href="/music/">Music</a>
    category = n.css('span[id^="cat_"]:first a:first')[0]
    is_music_category = category && category.text == "Music"

    song.file_name_in_torrent = filename
    # return false if not found...
    return (filename && is_music_category)
    
  rescue Exception => ex
    puts "ERROR ON SONG #{song.name}"
    puts "Error going to torrent page to verify"
    puts link
    puts ex.message
    puts ex.backtrace.join("\n")
    return false
  end

  def visit_site_on_google(song)
    song.google_results.each do |result|
      begin
        n=Nokogiri::HTML(HTTParty.get(result['url']))

        number_of_seeds = n.css('.seedBlock').text[-1].to_i
        
        if (number_of_seeds > 0)
          song.torrent_links << {
            seeds: number_of_seeds,
            'torrentLink' => n.css('.downloadButtonGroup a[rel=nofollow]')[0]['href']
          }
        end
      rescue URI::InvalidURIError => ex
        puts "ERROR ON SONG #{song.name}"
        puts "URI::InvalidURIError"
        puts result.inspect
        puts ex.message
        puts ex.backtrace.join("\n")
      end
    end
  end
end

