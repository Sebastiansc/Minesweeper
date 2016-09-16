require_relative 'player'
require_relative 'board'

class Minesweeper

  def initialize
    @board = Board.create_board(25)
    @player = Player.new
  end

  def run
    until over?
      move = @player.play
      @board.handle_move(move)
      display
    end
  end

  def display
    @board.render
  end

  def over?
    @board.over?
  end

end


game = Minesweeper.new
game.run
