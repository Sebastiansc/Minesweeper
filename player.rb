class Player

  def initialize(name = "billy")
    @name = name
  end

  def play
    puts "Pick a cell and mode (-f flag, -r reveal)"
    print ">"
    input = gets.chomp.split(" ")
    flag = input.shift
    position = input.map(&:to_i)
    [flag, position]
  end

end
