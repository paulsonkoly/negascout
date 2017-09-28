class NodeDouble
  def initialize(terminate_at: 10000)
    @number = 0
    @depth = 0
    @terminate_at = terminate_at
    @@count ||= 0
  end

  def evaluate
    @number
  end

  def moves(mode = :shuffle)
    case mode
    when :shuffle then (1..3).entries.shuffle!
    end
  end

  def move(move)
    @number += move
    @depth += 1
    @@count += 1
  end

  def unmove(move)
    @number -= move
    @depth -= 1
  end

  def terminal?
    @depth >= @terminate_at
  end

  def self.count
    @@count
  end
end

