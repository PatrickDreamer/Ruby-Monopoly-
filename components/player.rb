class Player
    attr_accessor :name, :money, :position, :game_over, :properties
  
    def initialize(name)
      @name = name
      @money = 16
      @position = 0
      @game_over = false
      @properties = []
    end
  
    def update_position(new_position)
      @position = new_position
    end
  
    def get_bonus
      @money += 1
    end
  
    def expense(amount)
      @money -= amount
    end
  
    def add_building(building)
      @buildings << building
    end
  
  end
 
