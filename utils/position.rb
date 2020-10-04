# frozen_string_literal: true

require_relative 'native.rb'

class Position
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    "{#{@x.round}:#{@y.round}}"
  rescue StandardError
    puts @x, @y
  end

  def range(pos)
    Native.range(x, pos.x, y, pos.y)
  end

  def move!(target, speed)
    target = get_real_position(target)

    #res = Native.move(x, y, target.x, target.y, speed)

    #@x = res >> 16;
    #@y = res & 65535;

    x_ratio = if (target.y - @y).zero? then 1
              else (target.x - @x) / (target.y - @y).abs
              end
    y_ratio = if (target.x - @x).zero? then 1
              else (target.y - @y) / (target.x - @x).abs
              end
    if x_ratio.abs > y_ratio.abs
      x_ratio /= x_ratio.abs
      y_ratio /= x_ratio.abs
    else
      x_ratio /= y_ratio.abs
      y_ratio /= y_ratio.abs
    end
    @x += x_ratio * speed
    @y += y_ratio * speed
  end

  def ==(pos)
    pos = get_real_position pos
    (pos.x - @x).abs <= 1.0 && (pos.y - @y).abs <= 1.0
  end

  def get_real_position(pos)
    pos.instance_of?(Position) ? pos : pos.position
  end
end
