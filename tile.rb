class Tile
  attr_accessor :flag, :value, :bomb, :shown

  def initialize(bomb = false, value = nil, shown = false)
    @flag = false
    @value = value ##bombs around tile
    @bomb = bomb
    @shown = shown
  end

  def reveal
    @shown = true
  end

end
