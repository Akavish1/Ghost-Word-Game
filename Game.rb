require 'set'
require_relative 'Player'

class Game

  attr_accessor :fragment, :current_player, :player_arr
  attr_reader :dictionary

  def initialize
    #the word fragment starts as an empty string and adds a letter each turn
    @fragment = ""
    @round = 1
    #a set that holds the possible words
    @dictionary = init_set
    #number of players in the game
    @players = number_of_players
    #holds the player objects
    @player_arr = get_player_name(@players)
    welcome
  end

  #greetings, instructions and shit
  def welcome
    print "\nWelcome to Ghost game "
    @player_arr.each {|player| player == @player_arr.last ? (print player.name) : (print "#{player.name}, ")}
    puts "\nEach player enters a character in his turn, and the first player to complete a valid word out of #{@dictionary.length} words loses the round!"
    puts "The first player to lose five rounds loses!"
  end

  #quite literally
  def get_player_name(num)
    player_arr = []
    #all this mess makes sure there arent any name duplicates
    num.times do |i|
      loop do
        puts "Enter name for player #{i+1}"
        name = gets.chomp
        if i == 0
          player_arr << Player.new(name)
          break
        end
        if player_arr[0..i-1].any? {|player| player.name == name} 
          puts "You are already in the game!"
          next
        end
        player_arr << Player.new(name) if i != 0
        break
      end
    end
    player_arr
  end

  #counts the-
  def number_of_players
    loop do
      puts "\nEnter the number of players between 2 and 4"
      input = gets.chomp.to_i
      (2..4).include?(input) ? (return input) : (puts "I said 2 and 4!!\n") 
    end
  end

  #initializes the dictionary from the given file
  def init_set
    File.open("dictionary.txt").reduce(Set.new) {|set, line| set.add(line.chomp)}
  end

  def next_player!
    @current_player = @player_arr[(player_number + 1) % @players]
  end

  #randomly chooses who plays first in a round
  def roll_dice
    chosen = rand(1..@players)
    puts "\nPlayer #{chosen} was randomly chosen to play first this round!"
    chosen-1
  end

  #prints how many words begin with each letter
  def print_frequency
    hash = Hash.new(0)
    @dictionary.each {|word| hash[word[0]] += 1}
    puts "First letter frequency -"
    print hash
  end

  #returns the current's player number in the array 
  def player_number
    @player_arr.index(@current_player)
  end

  #manages the gameplay of a single round
  def play_round
    puts "\nROUND #{@round}\n"
    #one turn for each player
    @players.times do |i|
      #takes input from a player and prints it
      print_play(take_input)
      status = check_word
      #if the current fragment isn't a part of any word the round is a draw, if the player has completed a word he loses the round
      return status if status == "draw" || status == "loss"
      #if its neither a draw nor a loss, have the next player play
      self.next_player!
    end
  end

  def print_player_status
    puts "GHOST status:"
    @player_arr.each {|player| puts "#{player.name}: #{player.ghost}"}
  end

  #takes input from player and adds it to the fragment
  def take_input
    puts "\n#{@current_player.name}, enter your guess"
    guess = @current_player.guess
    @fragment += guess
    guess
  end

  #prints the last play and the current state of the fragment
  def print_play(guess)
    puts "\n#{@current_player.name} entered #{guess}:"
    puts "\n-------------\nCurrent word: #{@fragment}\n-------------\n"
  end

  #checks whether a word is in the dictionary
  def check_word
    #loss if the exact word is in the dictionary
    if @dictionary.include?(@fragment)
      @round += 1
      puts "#{@fragment} is a word in the dictionary!"
      return "loss"
    end
    #draw if fragment isnt a part of any word
    @dictionary.each {|w| return if w.include?(@fragment)}
    "draw"
  end

  #core game logic
  def run
    #roll which player plays first
    @current_player = @player_arr[roll_dice]
    #keep going until only one player is left
    while @player_arr.size > 1
      round_value = play_round
      if round_value == "loss"
        loss_handler
        #reset the fragment after a loss or draw
        @fragment = ""
        next
      elsif round_value == "draw"
        puts "The round has ended in a draw!"
        @fragment = ""
        next
      end
      puts "End of round #{@round}"
      @round += 1
    end
    #go here if there's only one player remaining
    end_game
  end

  #declare the winner and exit
  def end_game 
    puts "\n\n#{@player_arr[0].name} IS VICTORIOUS!!!\n\n"
  end

  #check if loser of the round has been eliminated, delete him from the game if so
  def check_ghost
    return if !@current_player.eliminated? 
    puts "\n||#{@current_player.name} has become a GHOST and has been eliminated!||\n"
    @player_arr.delete(@current_player)
    #decrement the number of active players
    @players -= 1
    if @player_arr.size > 1
      print "\nRemaining players "
      print_player_status
      return false
    end
    true
  end

  #declare round loser, increment his GHOST status
  def loss_handler
    puts "#{@current_player.name} has lost the round!"
    @current_player.inc_ghost
    print_player_status
    #roll a new player to play first if the round has ended, ensure we don't roll if there's only one player left
    @current_player = @player_arr[roll_dice] if !check_ghost
  end

end


Game.new.run


