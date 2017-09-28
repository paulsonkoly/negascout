require_relative '../negascout'
module Negascout
  ##
  # Provides a shallow search first heuristics for the normal negascout.
  #
  # The normal negascout search is used apart from reordering the nodes first
  # with a shallow alpha beta search. The shallow depth is configurable.
  module Heuristics
    include ::Negascout

    extend self

    ##
    # @api callback
    #
    # {Negascout.moves} callback
    def moves(node, depth, alpha, beta, colour)
      with_option({null_window: false}) do
        node.moves.sort_by do |move|
          with_move(node, move) do
            depth = @options[:shallow_depth]
            # note that we have to call Negascout.negascout here as
            # self.negascout would be infinite recursion
            - (Negascout.negascout(node, depth, alpha, beta, colour).score)
          end
        end
      end
    end

    private

    def with_option(options)
      old_options = @options
      @options = @options.dup.merge(options)
      yield
    ensure
      @options = old_options
    end
  end
end
