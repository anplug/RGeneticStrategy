require_relative 'genotype.rb'

class Phenotype

  attr_reader :color, :attractiveness, :age, :strength, :size, :speed, :view_scope
  attr_accessor :satiety

  def initialize(color = :white, attractiveness = DEFAULT_ATTRACTIVENESS,
                 age = DEFAULT_AGE, strength = DEFAULT_STRENGTH,size = DEFAULT_SIZE,
                 speed = DEFAULT_SPEED,view_scope = DEFAULT_VIEW_SCOPE)
    @age = age
    @color = color
    @strength = strength
    @size = size
    @speed = speed
    @view_scope = view_scope
    @satiety = INITIAL_SATIETY
    @attractiveness = attractiveness

    @update_sprite_flag = false
  end

  def update_sprite?
    @update_sprite_flag
  end

  def to_s
    "#{@attractiveness.round 3}, #{@age.round 3}, #{@strength.round 3}, #{@size.round 3}, #{@speed.round 3}"
  end

  def absolute_size
    @size * SIZE_COEFFICIENT
  end

  def maximum_size?
    absolute_size >= MAXIMUM_SIZE
  end

  def positive_feed_factor
    (@satiety**3).abs/1.0
  end

  def negative_feed_factor
    (@satiety**3)/1.0
  end

  def update(genotype, is_moving)
    update_age
    update_strength genotype
    update_size genotype
    update_speed
    update_view_scope genotype
    update_satiety is_moving
  end

  # Parameter updaters

  def update_age
    @age += AGE_INCR
  end

  def update_strength(genotype)
    @strength += genotype.strengthability * STRENGTH_INCR * negative_feed_factor
  end

  def update_size(genotype)
    # TODO : individual's size doesn't have to have restriction
    unless maximum_size?
      prev_size = absolute_size
      @size += genotype.sizeability * SIZE_INCR * positive_feed_factor
      @update_sprite_flag = absolute_size.to_i - prev_size.to_i != 0
    end
  end

  def update_speed
    size_strength_coef = @strength / @size
    size_strength_coef *= -1 if size_strength_coef <= STRENGTH_TO_SIZE_MAX_COEF
    @speed += SPEED_INCR * size_strength_coef
  end

  def update_view_scope(genotype)
    @view_scope -= VIEW_SCOPE_INCR * (1 / genotype.survivability)
  end

  def update_satiety(is_moving)
    @satiety -= (SATIETY_INCR * @size * positive_feed_factor + (is_moving ? SATIETY_INCR : 0))
  end



end