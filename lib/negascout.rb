require "negascout/version"

##
# The following example shows how to use negascout search on a custom Node type.
# In order to the {#negascout} to work the node type has to respond to at least
# +:evaluate+, +:moves+, +:move!+, +:unmove!+ and +:terminal?+ as shown in the
# following example:
#
#   class Node
#     def initialize(n = 0)
#       @number = n
#     end
#
#     def evaluate
#       @number
#     end
#
#     def moves
#       (1..3).entries.shuffle!
#     end
#
#     def move(move)
#       @number += move
#     end
#
#     def unmove(move)
#       @number -= move
#     end
#
#     def terminal?
#       false
#     end
#   end
#
#   Negascout.negascout(Node.new, 10, -100, 100, 1) # =>
#     #<Negascout::SearchResult:0x0000556b15b67530 @score=20, @best_line=[3, 1, 3]>
#
# We can extend the search with a transposition cache.
# One can also include the +depth+ at which the node is inserted in the cache
# and return only if the cached value is "deep enough" or update the cache only
# if the cached value is "shallower" than the current evaluation.
#
#   class MySearch
#     include Negascout
#
#     def initialize
#       @cache = {}
#     end
#
#     def cache_insert(node, depth, value)
#       @cache[node.hash] = value
#     end
#
#     def cache_lookup(node, depth)
#       @cache[node.hash]
#     end
#   end
#
module Negascout
  ##
  # {#negascout} function return type
  #
  class SearchResult
    # @!attribute [r] score
    # @return the resulting evaluation
    attr_reader :score
    # @!attribute [r] best_line
    # @return the best moves for both player to the specified depth
    attr_reader :best_line

    # @private
    def initialize(score, best_line = [])
      @score = score
      @best_line = best_line
    end

    # @private
    def negate!
      @score *= -1
      self
    end

    # @private
    def <<(move)
      @best_line.unshift move
      self
    end
  end

  extend self

  ##
  # Default options are used unless option is given
  # * +null_window+ : # apply null window or fall back to normal alpha-beta
  # * +shallow_depth+ : used in {Negascout::Heuristics}. Note that 0 means 1
  #   level as we implicitly descend to the immediate children
  DEFAULT_OPTIONS = { null_window: true, shallow_depth: 0 }

  ##
  # Negascout search function
  #
  # @param node current state of the game
  # @param depth the depth of the search
  # @param alpha the initial alpha value
  # @param beta the initial beta value
  # @param colour the +1 if the next player to move tries to maximize the
  #   evaluation, -1 if minimize
  # @param opts see {DEFAULT_OPTIONS} for available options
  # @return [SearchResult] the best line and the evaluation
  #
  def negascout(node,
                depth = 10,
                alpha = (-Float::Infinity),
                beta = Float::Infinity,
                colour = 1,
                opts = {})
    @options ||= DEFAULT_OPTIONS
    @options.merge!(opts)
    negascout_intern(node, depth, alpha, beta, colour)
  end

  ##
  # @api callback
  #
  # Callback for shortcutting the search and do a cache lookup instead.
  #
  # The cache should respond with +nil+ if not found. The depth can also be used
  # as a measure of information reliability.
  #
  # @param _node the node to look up
  # @param _depth the current depth of the search
  # @return [Numeric, nil] the evaluation on hit
  # @note The default implementation just returns +nil+.
  #
  def cache_lookup(_node, _depth)
    nil
  end

  ##
  # @api callback
  #
  # Callback for inserting a node into the cache.
  #
  # The current depth is also supplied together with the evaluation from the
  # search.
  #
  # @param _node the node to insert
  # @param _depth the current depth of the search
  # @param _deep_eval the evaluation returned from the search for the +node+
  # @note The default implementation does nothing.
  #
  def cache_update(_node, _depth, _deep_eval); end

  ##
  # @api callback
  #
  # Callback for generating move list based on depth, alpha or beta. Useful for
  # search based heuristics, see {Negascout::Heuristics}.
  # @note Default implementation just returns +node.moves+
  def moves(node, _depth, _alpha, _beta, _colour)
    node.moves
  end


  private

  def negascout_intern(node, depth, alpha, beta, colour)
    with_cache(node, depth, colour) do
      # terminal node
      return SearchResult.new(colour * node.evaluate) if depth.zero? ||
                                                         node.terminal?
      maximize_alpha(node, depth, alpha, beta, colour)
    end
  end

  def with_cache(node, depth, colour)
    value = cache_lookup(node, depth)
    return colour * value if value
    value = yield
  ensure
    cache_update(node, depth, value)
    value
  end

  def maximize_alpha(node, depth, alpha, beta, colour)
    best_result = SearchResult.new alpha
    moves(node, depth, alpha, beta, colour).each.with_index do |move, ix|
      result = with_move(node, move) do
        search(ix.zero?, node, depth, alpha, beta, colour)
      end
      if result.score > alpha
        best_result = result << move
        alpha = result.score
      end
      break if alpha >= beta
    end
    best_result
  end

  def with_move(node, move)
    node.move(move)
    yield
  ensure
    node.unmove(move)
  end

  def search(first, child, depth, alpha, beta, colour)
    depth -= 1
    colour *= -1
    if first || ! @options[:null_window]
      negascout_intern(child, depth, -beta, -alpha, colour)
    else
      result = negascout_intern(child, depth, -alpha - 1, -alpha, colour)
      score = - result.score
      if alpha < score && score < beta
        negascout_intern(child, depth, -beta, -score, colour)
      else
        result
      end
    end.negate!
  end
end
