#!/usr/bin/env ruby
#
# Quick class to encompass a pair of values, pretty basic
#

class Pair
  attr_reader :lhs, :rhs
  def initialize(a,b)
    @lhs,@rhs = a,b
    @color_a = %x(/usr/bin/tput setaf 2)
    @color_b = %x(/usr/bin/tput setaf 6)
    @reset = %x(/usr/bin/tput sgr0)
  end
  def ==(x)
    return ((x.class.to_s == "Pair") and ((x.lhs == @lhs) and (x.rhs == @rhs))) ? true : false
  end
  def <=>(x)
    return (x.lhs == lhs) ? rhs <=> x.rhs : lhs <=> x.lhs
  end
  def includes?(x)
    return  case x
      when @rhs then true
      when @lhs then true
      else
        false
      end
  end
  def to_s
    return "#{@color_a}#{@lhs}#{@reset} <=> #{@color_b}#{@rhs}#{@reset}"
  end
  def length
    return "#{@lhs} <=> #{@rhs}".scan(/./u).size
  end
end
