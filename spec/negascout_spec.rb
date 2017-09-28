require "spec_helper"

RSpec.describe Negascout do
  it "has a version number" do
    expect(Negascout::VERSION).not_to be nil
  end

  describe '#negascout' do
    let(:node) { NodeDouble.new }

    it "returns the correct score" do
      result = Negascout.negascout(node, 10, -100, 100, 1)
      expect(result.score).to be 20
    end

    it "returns the correct best line" do
      result = Negascout.negascout(node, 10, -100, 100, 1)
      expect(result.best_line).to eq [3,1].cycle.take(result.best_line.length)
    end

    it "stops at terminal nodes" do
      only_three = NodeDouble.new terminate_at: 3
      result = Negascout.negascout(only_three, 10, -100, 100, 1)
      expect(result.score).to be 7
    end

    def self.it_doesnt_go_beyond_depth(depth_limit)
      context "with the depth limited to #{depth_limit}" do
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
