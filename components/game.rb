require 'json'
require_relative "../components/property"
require_relative "../components/player"

board_data = '../specs/board.json'
players_data = '../specs/players.json'
roll_data = '../specs/rolls_1.json' 

class Game
  attr_accessor :properties, :players, :roll
  def initialize(board_data, players_data, roll_data)
    board = JSON.parse(File.read(board_data))
    @properties = board.map { |b| Property.new(b) }
    players = JSON.parse(File.read(players_data))
    @players = players.map { |p| Player.new(p) }
    @roll = JSON.parse(File.read(roll_data))
  end
  # update current position of player
  def move(dice, player)
    current_position = player.position
    new_position = (current_position + dice) % @properties.length
    # Get $1 bonus when player passes GO excludes the starting move
    if current_position + dice >= @properties.length
      player.get_bonus
    end
    # update the new position
    player.update_position(new_position)
  end
  # determine to buy or rent properties once player moves
  def buy_rent(player)
    if player.position != 0
      current_property = @properties[player.position]
      # If you land on a property, you must buy it
      if current_property.owner == "nil"
        player.money -= current_property.price
        current_property.owner = player
        player.properties.push(current_property)
        # If the same owner owns all property of the same colour, the rent is doubled
        if player.properties.length > 1
          property_owner = @properties.find_all {|b| b.colour == current_property.colour}
          if property_owner.all? { |b| player.properties.include?(b)}
            property_owner.each{ |b| b.price *= 2}
          end
        end
      # If you land on an owned property, you must pay rent to the owner
      elsif current_property.owner != player
        player.money -= current_property.price
        current_property.owner.money += current_property.price
      end
    end
  end

  # End the game if any player is bankrupt
  def end_game(player, players)
    if player.money < 0
      player.game_over = true
      puts "\n#{player.name} is brankrupt! Gameover! \n"
      find_winner(players)
      return true
    end
  end

  # Find the winner with the most money remaining
  def find_winner(players)
    max_money = players.max_by{ |p| p.money }.money
    winners = players.select { |p| p.money == max_money }.map { |p| p.name }
    puts "\nWinner: #{winners}\n"
    puts "\nDetails are shown below\n"
    @players.each_with_index do |e, i|
        b = @properties[e.position]
        puts "Player #{i + 1}: #{e.name} | money: $#{e.money} | properties: #{e.properties.length}"
      end
  end
end

# Provide instructions before starting the game:



puts "\n Here is some instructions for you before starting the game: \n"

puts "\n
* Each player starts with $16 \n
* Everybody starts on GO \n
* You get $1 when you pass GO (this excludes your starting move) \n
* If you land on a property, you must buy it \n
* If you land on an owned property, you must pay rent to the owner \n
* If the same owner owns all property of the same colour, the rent is doubled \n
* Once someone is bankrupt, whoever has the most money remaining is the winner \n
* There are no chance cards, jail or stations \n
* The board wraps around (i.e. you get to the last space, the next space is the first space) \n"

puts "\n Are you ready to start the game? Yes or No \n"

# get the answer from user
answer = gets.chomp

# Create a new game
game = Game.new(board_data, players_data, roll_data)

# Ask if the user want to start the game:
if answer.downcase == "yes" 
puts"\nGame now start! Start rolling dice\n"
puts"\nNow You can see the results as below,"
roll_arr = game.roll
players_arr = game.players
 
roll_arr.each_with_index do |roll, i|
  current_player = players_arr[i % players_arr.length]
  # Have the current player move and pay rent
  game.move(roll, current_player)
  game.buy_rent(current_player)
  # when to end the game
  if game.end_game(current_player, players_arr) == true
    break
  end
end
else puts "\n Not a good time, come next time! See you!\n"

end
