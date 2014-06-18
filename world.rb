require_relative 'individual.rb'
require_relative 'position.rb'
require_relative 'genotype.rb'
require_relative 'phenotype.rb'
require_relative 'food.rb'
require_relative 'util.rb'

class World

  include Util

  def initialize(window, size, to_load_individuals)
    Position.inject_size(size)
    @size = size
    @window = window
    @individuals = []
    @food_points = []

    @new_individuals = []
    @dead_individuals = []

    init_individuals to_load_individuals
    init_food
  end

  def init_individuals(to_load_individuals)
    if to_load_individuals
      IndividualsLoader.set_window @window
      IndividualsLoader.set_world_size @size
      @individuals = IndividualsLoader.load
    else
      add_random_individuals(INDIVIDUALS_NUMBER)
    end
  end

  def init_food
    add_random_food_points FOOD_POINTS_NUMBER
  end

  def update
    update_individuals_list
    @individuals.each do |ind|
      ind.set_near_individuals(near_individuals ind)
      ind.set_near_food(near_food ind)
      ind.update
      reproduction_pair = ind.get_reproduction_pair
      if reproduction_pair
        generate_new_individual reproduction_pair
      end
      if ind.is_dead
        kill_individual ind
      end
    end
    @food_points.each {|fp| fp.update}
    @food_points = @food_points.find_all {|fp| !fp.empty?}
  end

  def near_individuals(individual)
    near_individuals = @individuals.find_all {|ind| individual.in_view_scope? ind unless individual.equal? ind}
    near_individuals.empty? ? nil : near_individuals
  end

  def near_food(individual)
    near_food = @food_points.find_all {|fp| individual.in_view_scope? fp}
    near_food.empty? ? nil : near_food
  end
  
  def draw
    @individuals.each {|ind| ind.draw}
    @food_points.each {|fp| fp.draw}
  end

  def add_random_individuals(count)
    count.times do
      genotype = Genotype.default
      phenotype = Phenotype.default genotype
      position = Position.random
      @individuals << create_individual(@window, @size, position, genotype, phenotype)
    end
  end

  def add_random_food_points(count)
    count.times do
      @food_points << Food.new(@window, @size, Position.new(Random.rand(@size.w), Random.rand(@size.h)))
    end
  end

  def generate_new_individual(pair)
    genotype = Genotype.genotype_crossing(pair[0].genotype, pair[1].genotype)
    phenotype = Phenotype.default genotype
    position = Position.new(pair.first.position.x, pair.first.position.y)
    @new_individuals << create_individual(@window, @size, position, genotype, phenotype)
  end

  def kill_individual(ind)
    @dead_individuals << ind
  end

  def update_individuals_list
    if @new_individuals.any?
      @individuals += @new_individuals
      @new_individuals = []
    end
    if @dead_individuals.any?
      @individuals -= @dead_individuals
      @dead_individuals = []
    end
  end

end
