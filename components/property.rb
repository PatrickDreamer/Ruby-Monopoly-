class Property
  attr_accessor :name, :price, :colour, :type, :owner

  def initialize(space)
    @name = space["name"]
    @price = space["price"]
    @colour = space["colour"]
    @type = space["type"]
    @owner = "nil"
  end

end
