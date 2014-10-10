class TorrentFileSaver
  require 'net/http'
  require 'tempfile'
  require 'uri'

  attr_accessor :parser
  def initialize(parser)
    self.parser = parser
  end

  def save_to_file(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.get(uri.path)
      file = Tempfile.new('foo', Dir.tmpdir, 'wb+')
      file.write(resp.body)
      file.flush
      file
    end
  end

end