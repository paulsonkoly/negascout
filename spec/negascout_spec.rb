require "spec_helper"

class NodeDouble
  def initialize(mode = :shuffle, terminate_at = 10000)
    @number = 0
    @depth = 0
    @terminate_at = terminate_at
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
  end

  def unmove(move)
    @number -= move
    @depth -= 1
  end

  def terminal?
    @depth >= @terminate_at
  end
end

RSpec.describe Negascout do
  it "has a version number" do
    expect(Negascout::VERSION).not_to be nil
  end

  describe '#negascout' do
    def self.it_doesnt_go_beyond_depth(depth_limit)
      context "with the depth limited to #{depth_limit}" do
        let(:node) { NodeDouble.new }

        it "doesn't go beyond depth limit" do
          result = Negascout.negascout(node, depth_limit, -100, 100, 1)
          expect(result.best_line.length).to be <= depth_limit
        end
      end
    end

    it_doesnt_go_beyond_depth 2
    it_doesnt_go_beyond_depth 3
    it_doesnt_go_beyond_depth 4
    it_doesnt_go_beyond_depth 10
  end
end
