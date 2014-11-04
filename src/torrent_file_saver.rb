class TorrentFileSaver
  require 'net/http'
  require 'uri'
  require 'securerandom'

  attr_accessor :parser
  def initialize(parser=nil)
    self.parser = parser
  end

  def clear_torrents
    FileUtils.rm_rf(Dir.glob('torrents/*'))
  end

  def save_to_file(song)
    torrent_json = song.sorted_torrents.first

    uri = URI.parse(torrent_json['torrentLink'])
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.get(uri.path)
      open(song.saved_file = "torrents/#{song.name}.torrent", "wb") do |file|
        file.write(resp.body)
      end
    end
  end
end