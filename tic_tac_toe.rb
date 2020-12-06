# frozen_string_literal: true

class Game
  def initialize
    @rows = [%w[1 2 3], %w[4 5 6], %w[7 8 9]]
    @players = []
    @taken_squares = []
  end

  def start_game
    display_board
    get_names
    turn_loop(@players)
  end

  def display_board
    puts " #{@rows[0][0]} | #{@rows[0][1]} | #{@rows[0][2]} "
    puts '-----------'
    puts " #{@rows[1][0]} | #{@rows[1][1]} | #{@rows[1][2]} "
    puts '-----------'
    puts " #{@rows[2][0]} | #{@rows[2][1]} | #{@rows[2][2]} "
  end

  def get_names
    puts 'Welcome to ' + 'Noughts & Crosses'.bold + '. Please enter your name:'
    @players.push(Player.new(gets.chomp.capitalize.red, 'X'.red))
    puts "Greetings, #{@players[0].name}. I see you brought a friend. I'll be needing their name, too:"
    @players.push(Player.new(gets.chomp.capitalize.green, 'O'.green))
    puts "\n\n#{@players[0].name} vs. #{@players[1].name}"
  end

  def turn_loop(players)
    loop do
      turn(players[0])
      turn(players[1])
    end
  end

  def turn(player)
    display_board
    puts "\n#{player.name}'s turn: "
    square = gets.chomp

    if validate_choice?(square)
      print_choice(square, player)
      @taken_squares.push(square)
    else puts "\n\nInvalid choice. Try again.".red
         turn(player)
    end

    check_result(player)
  end

  def validate_choice?(square)
    return true if !@taken_squares.include?(square) && square.to_i < 10 && square.to_i.positive?
  end

  def print_choice(square, player)
    @rows.each do |row|
      row[row.index(square)] = player.token if row.include?(square)
    end
  end

  def check_result(player)
    if diagonal_victory || vertical_victory || horizontal_victory
      player.win
      end_game("#{player.name} wins!")
    elsif @taken_squares.length == 9
      end_game('Draw!')
    end
  end

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

  def end_game(message)
    display_board
    puts message
    show_score
    rematch
  end

  def win(player)
    display_board
    puts "\n#{player.name} wins!\n\n"
    player.wins += 1
    show_score
    rematch(player)
  end

  def draw(players)
    display_board
    puts "\nDraw!\n\n"
    show_score
    rematch(players)
  end

  def rematch
    puts 'Rematch? Y/N'

    if gets.chomp.downcase == 'y'
      reset_game
      turn_loop(@players.swap!(0, 1))
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
    uniq.length === 1
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

new_game = Game.new
new_game.start_game
