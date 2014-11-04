class Song
  attr_accessor :name, 
  # what it found from kickass.to,
  # if there are some here do nothing else
  :torrents,

  :google_results, 

  # this is what it finds through google if couldn't find any on kickass.to
  #ones found by google
  :torrent_links,
  :file_name_in_torrent,
  :saved_file

  def initialize(name)
    self.name = name
    self.torrents = []
    self.google_results = nil
    self.torrent_links = []
    self.saved_file = nil
    self.file_name_in_torrent = nil
  end

  # either kind of torrent sorted by seeds desc
  def sorted_torrents
    (torrents + torrent_links).sort { |a,b|
      b['seeds'] <=> a['seeds']
    }
  end
end