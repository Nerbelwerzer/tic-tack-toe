# frozen_string_literal: true

class Board
  def initialize
    @rows = [%w[1 2 3], %w[4 5 6], %w[7 8 9]]
    @taken_squares = []
  end

  def display
    puts " #{@rows[0][0]} | #{@rows[0][1]} | #{@rows[0][2]} "
    puts '-----------'
    puts " #{@rows[1][0]} | #{@rows[1][1]} | #{@rows[1][2]} "
    puts '-----------'
    puts " #{@rows[2][0]} | #{@rows[2][1]} | #{@rows[2][2]} "
  end

  def print_choice(square, token)
    @rows.each do |row|
      row[row.index(square)] = token if row.include?(square)
    end
    @taken_squares.push(square)
  end

  def available?(square)
    @taken_squares.none?(square)
  end

  def game_win
    diagonal_victory || vertical_victory || horizontal_victory
  end

  def game_draw
    @taken_squares.length == 9
  end

  private

  def diagonal_victory
    left_diagonal = [@rows[0][0], @rows[1][1], @rows[2][2]]
    right_diagonal = [@rows[0][2], @rows[1][1], @rows[2][0]]

    left_diagonal.all_equal? || right_diagonal.all_equal?
  end

  def horizontal_victory
    @rows.any?(&:all_equal?)
  end

  def vertical_victory
    @rows.transpose.any?(&:all_equal?)
  end
end

class Game
  def initialize(board)
    @players = []
    @board = board
  end

  def start_game
    @board.display
    get_names
    game_loop(@players)
  end

  def get_names
    puts 'Welcome to ' + 'Noughts & Crosses'.bold + '. Please enter your name:'
    @players.push(Player.new(gets.chomp.capitalize.red, 'X'.red))
    puts "Greetings, #{@players[0].name}. I see you brought a friend. I'll be needing their name, too:"
    @players.push(Player.new(gets.chomp.capitalize.green, 'O'.green))
    puts "\n\n#{@players[0].name} vs. #{@players[1].name}"
  end

  def game_loop(players)
    loop do
      turn(players[0])
      turn(players[1])
    end
  end

  def turn(player)
    @board.display
    puts "\n#{player.name}'s turn: "
    choice = gets.chomp

    if validate_choice?(choice)
      @board.print_choice(choice, player.token)
    else puts "\n\nInvalid choice. Try again.".red
         turn(player)
    end

    check_result(player)
  end

  def validate_choice?(choice)
    @board.available?(choice) && choice.to_i < 10 && choice.to_i.positive?
  end

  def check_result(player)
    if @board.game_win
      player.win
      end_game("#{player.name} wins!")
    elsif @board.game_draw
      end_game('Draw!')
    end
  end

  def end_game(message)
    @board.display
    puts message
    show_score
    rematch
  end

  def rematch
    puts 'Rematch? Y/N'

    if gets.chomp.downcase == 'y'
      reset_game
      game_loop(@players.swap!(0, 1))
    else
      exit
    end
  end

  def reset_game
    @rows = [%w[1 2 3], %w[4 5 6], %w[7 8 9]]
    @taken_squares = []
  end

  def show_score
    puts "#{@players[0].name}  #{@players[0].wins} | #{@players[1].wins}  #{@players[1].name}"
  end
end

class Array
  def swap!(a, b)
    self[a], self[b] = self[b], self[a]
  end

  def all_equal?
    uniq.length == 1
  end
end

class Player
  attr_reader :name, :token
  attr_accessor :wins
  def initialize(name, token)
    @name = name.length > 9 ? name[0..16].bold : 'Player'.bold # > 9 because those fancy colours add a lot of letters!
    @token = token
    @wins = 0
  end

  def win
    @wins += 1
  end
end

class String
  def green
    "\e[32m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end

new_game = Game.new(Board.new)
new_game.start_game
