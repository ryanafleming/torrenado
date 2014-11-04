class TorrentFileSaver
  require 'net/http'
  require 'uri'
  require 'securerandom'

  attr_accessor :parser
  def initialize(parser=nil)
    self.parser = parser
  end

  def songs_with_torrents
    parser.songs.select { |song|
      song.sorted_torrents.first
    }
  end

  def save_all
    # remove old torrents.
    FileUtils.rm_rf(Dir.glob('torrents/*'))

    songs_with_torrents.each { |song|
      save_to_file(song)
    }
  end

  def save_to_file(song)
    torrent_json = song.sorted_torrents.first

    uri = URI.parse(torrent_json['torrentLink'])
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.get(uri.path)
      open(song.saved_file = "torrents/#{SecureRandom.uuid}.torrent", "wb") do |file|
        file.write(resp.body)
      end
    end
  end
end