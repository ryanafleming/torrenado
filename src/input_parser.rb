class InputParser

  attr_accessor :songs, :in_file, :out_file

  def initialize(in_file, out_file)
    self.in_file = in_file
    self.out_file = out_file
    self.songs = []
  end

  def read_file
    f = File.open(in_file, "r")
    f.each_line do |line|
      songs << line.split("+")[1].split("\r")[0]
    end
    f.close
  end

end

