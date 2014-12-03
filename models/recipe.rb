class Recipe
  attr_accessor :recipes, :id, :name, :ingredients, :description, :instructions
  def initialize (name,id)
    @name = name
    @id = id
    @ingredients = nil
  end

  def self.get_data(query,id)
    if id != nil
    results = PsqlCon.connect do |conn|
        conn.exec_params(query,[id])
      end
    else
      results = PsqlCon.connect do |conn|
        conn.exec(query)
      end
    end
    results
  end

  def self.all
    @result = []
    query = 'SELECT recipes.name, recipes.id FROM recipes'
    @recipes = get_data(query,nil)
    @recipes.each do |name|
      recipe = Recipe.new(name["name"],name["id"])
      @result << recipe
    end
    @result
  end

  def self.find(id)
    query = 'SELECT recipes.id, recipes.name, recipes.description, recipes.instructions, ingredients.name AS ingredients
    FROM recipes
    JOIN ingredients ON recipes.id = ingredients.recipe_id
    WHERE recipes.id = $1'
    result = get_data(query,id)
    recipe = Recipe.new(result[0]["name"],result[0]["id"])
    recipe.ingredient(id)
    recipe.details(id)
    recipe
  end
  def ingredient(id)
    @ingredients = []
    query = 'SELECT recipes.id, ingredients.name
    FROM recipes
    JOIN ingredients ON recipes.id = ingredients.recipe_id
    WHERE recipes.id = $1'
    results = Recipe.get_data(query,id)
    results.each do |result|
      @ingredients << Ingredient.new(result["name"])
    end
  end
  def details(id)
    query = 'SELECT recipes.description, recipes.instructions
    FROM recipes
    JOIN ingredients ON recipes.id = ingredients.recipe_id
    WHERE recipes.id = $1'
    results = Recipe.get_data(query,id)
    @description = results[0]["description"]
    @instructions = results[0]["instructions"]
  end
end
