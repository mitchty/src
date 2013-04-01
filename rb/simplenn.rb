require 'set'

MINACT, REST, THRESH, DECAY, MAXACT = -0.2, -0.1, 0.0, 0.1, 1.0
ALPHA, GAMMA, ESTR = 0.1, 0.1, 0.4
$units, $pools, $unitbyname = Array.new, Array.new, Hash.new

class Array
  def sum
    self.inject(:+)
  end
end

class Unit
  attr_accessor :name, :pool, :extinp, :activation, :output, :exciters, :newact
  def initialize(name, pool)
    self.name = name
    self.pool = pool
    self.reset
    self.exciters = Array.new
    $unitbyname[self.name] = self
  end
  def reset
    self.setext(0.0)
    self.setactivation(REST)
  end
  def setext(weight=1.0)
    self.extinp = weight
  end
  def setactivation(val)
    self.activation = (val) ? val : REST
    self.output = Array[THRESH,self.activation].max
  end
  def addexciter(aunit)
    self.exciters.push(aunit)
  end
  def remove(aunit)
    self.exciters - Array[aunit]
  end
  def computenewact
    ai = self.activation
    plus = self.exciters.collect {|x| x.output }.sum
    minus = self.pool.sum - self.output
    netinput = ALPHA*plus - GAMMA*minus + ESTR*self.extinp
    if netinput > 0
      ai = (MAXACT - ai)*netinput - DECAY*(ai - REST) + ai
    else
      ai = (ai - MINACT)*netinput - DECAY*(ai - REST) + ai
    end
    self.newact = Array[Array[ai,MAXACT].min, MINACT].max
  end
  def commitnewact
    self.setactivation(self.newact)
  end
end

class Pool
  attr_accessor :sum, :members
  def initialize
    self.sum = 0.0
    self.members = Set.new
  end
  def addmember(member)
    self.members.add(member)
  end
  def updatesum
    self.sum = self.members.collect {|x| x.output}.sum
  end
  def display
    result = self.members.collect {|x| Array[x.activation, x.name]}.sort.reverse
    out = 0
    result.each_index do |i|
      name, match = result[i][1], result[i][0]
      if match > THRESH
        printf "%8s:%1.2f   ", name, match
        if out == 3
          out = 0
          print "\n"
        end
        out += 1
      end
    end
    puts
  end
end

def Load_file(file)
  File.open(file).each do |line|
    relatedunits = line.chomp.split(/\s+/)
    next unless relatedunits.size > 0
    key = $units.size
    relatedunits.each_index do |i|
      name = relatedunits[i]
      if i >= $pools.size
        $pools.push(Pool.new)
      end
      pool = $pools[i]
      if $unitbyname.include?(name)
        unit = $unitbyname[name]
      else
        unit = Unit.new(name, pool)
        $units.push(unit)
      end
      pool.addmember(unit)
      if i > 0
        $units[key].addexciter(unit)
        unit.addexciter($units[key])
      end
    end
  end
end

def NNReset
  $units.each do |unit|
    unit.reset
  end
end

def Depair(i, j)
  $unitbyname[i].remove($unitbyname[j])
  $unitbyname[j].remove($unitbyname[i])
end

def Touch(item, weight)
  item.split(/\s+/).each do |x|
    $unitbyname[x].setext(weight)
  end
end

def Run(cycles)
  0.upto(cycles).to_a.each do |i|
    $pools.each do |pool|
      pool.updatesum
    end
    $units.each do |unit|
      unit.computenewact
    end
    $units.each do |unit|
      unit.commitnewact
    end
#    print i;puts "-" * 20
    $pools.each do |pool|
      pool.display if i == cycles
    end
  end
end

filename = "/tmp/jets.txt" || ARGV[0]
Load_file(filename)
Touch('Ken', 0.8)
Run(1000)
puts
NNReset()
Touch('Sharks 20 jh sing burglar', 1.0)
Run(1000)
puts
NNReset()
Touch('Lance', 1.0)
Depair('Lance', 'burglar')
Run(1000)
puts
