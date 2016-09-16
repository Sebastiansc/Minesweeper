require_relative 'tile'
require 'byebug'
require 'set'
class Board

  def self.create_board(bombs)
    board = Array.new(9) { Array.new(9) }
    self.new(board, bombs)
  end

  attr_reader :bomb_cells
  def initialize(board, bombs)
    @board = board
    @bombs = bombs
    @explored = Set.new ##used by #fringe
    @children = Hash.new
    @open = []
    fill_board
  end

  def render
    output = ""
    @board.each do |row|
     row.each do |tile|
       if tile.bomb
         output << " B "
       elsif tile.flag
         output << " F "
       elsif tile.shown
          output = tile.value ? "#{tile.value}" : "_"
       else
         output << " # "
       end
     end
     output << "\n"
    end
    puts output
  end

  def handle_move(move)
    move.first == "f" ? flag_cell(move) : reveal(move)
  end

  def over?
    @board.flatten.any?{ |tile| bomb }
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @board[row][col] = value
  end

  private

  def fringe(pos)
    @open = [pos]
    @explored.add(pos)

    until @open.empty?
      next_positions = []
      @open.each do |pos|
        next unless none_empty?(pos)
        neighbors = cardinals(pos)
        @children[pos] ||= []
        @children[pos].concat(neighbors)
        @explored << neighbors
        neighbors.reject!{ |pos| self[pos].value || @explored.include?(pos)}
        next_positions.concat(neighbors)
      end
      @open.clear
      @open.concat(next_positions)
    end
  end

  def map_fringe
    fringe_area = []
    @children.each_value{ |area| fringe_area.concat(area) }
    fringe_area.each{ |pos| self[pos].reveal }
  end

  def none_empty?(pos)
    cardinals(pos).any?{ |pos| !self[pos].value && !@explored.include?(pos) }
  end

  def flag_cell(move)
    self[move].flag = true
  end

  def reveal(move)
    if self[move].bomb
      map_bombs
    elsif self[move].value
      self[move].reveal
    else
      self[move] = bomb_neighbors(move)
      fringe(move)
    end
  end

  def map_bombs
    @bomb_cells.each{ |pos| self[pos].bomb = true }
  end

  def positions
    (0..8).to_a.repeated_permutation(2).to_a
  end

  def fill_board
    positions.each{ |pos| self[pos] = Tile.new(false) }
    populate_bombs
    positions.each{ |pos| bomb_neighbors(pos) }
  end

  def populate_bombs
    @bomb_cells = positions.shuffle.take(@bombs)
    @bombs.times{ |i| self[@bomb_cells[i]].bomb = true }
  end

  def bomb_neighbors(pos)
    neighbors = cardinals(pos)
    bomb_count = neighbors.count {|pos| self[pos].bomb}
    self[pos].value = bomb_count
  end

  def cardinals(pos)
    positions = [
      [pos[0]+1, pos[1]],
      [pos[0]-1, pos[1]],
      [pos[0], pos[1] + 1],
      [pos[0], pos[1] - 1],
      [pos[0] - 1, pos[1] - 1],
      [pos[0] + 1, pos[1] + 1],
      [pos[0] + 1, pos[1] - 1],
      [pos[0] - 1, pos[1] + 1]
    ]
    positions.reject{ |pos| pos.any?{ |n| n < 0 || n > 8 } }
  end
end

board = Board.create_board(25)
