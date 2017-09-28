require 'negascout/heuristics'

RSpec.describe Negascout::Heuristics do
  describe '#negascout' do
    let(:node) { NodeDouble.new }

    it "returns the correct score" do
      result = Negascout::Heuristics.negascout(node, 10, -100, 100, 1)
      expect(result.score).to be 20
    end

    it "returns the correct best line" do
      result = Negascout::Heuristics.negascout(node, 10, -100, 100, 1)
      expect(result.best_line).to eq [3,1].cycle.take(result.best_line.length)
    end

    it 'reduces the number of visited nodes' do
      count_before = NodeDouble.count
      Negascout.negascout(node, 10, -100, 100, 1)
      count_middle = NodeDouble.count
      Negascout::Heuristics.negascout(node, 10, -100, 100, 1)
      count_after = NodeDouble.count
      expect(count_middle - count_before > count_after - count_middle).to be
    end
  end
end
