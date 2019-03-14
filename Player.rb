class Player

  attr_accessor :name, :ghost

  #number of player objects created
  @@num_of_players = 0

  def initialize(name)
    @name = name
    @@num_of_players += 1
    @num = @@num_of_players
    #lives remaining
    @ghost = ""
  end

  #increment the GHOST counter (decrement one life)
  def inc_ghost
    "GHOST".each_char do |c|
      if !@ghost.include?(c)
        @ghost += c
        return
      end
    end
  end

  def eliminated?
    @ghost == "GHOST"
  end

#have the user make a valid guess
  def guess
    loop do
      input = gets.chomp
      ("a".."z").include?(input) ? (return input) : (puts "Invalid input - single English-alphabet characters only")
    end
  end

end


