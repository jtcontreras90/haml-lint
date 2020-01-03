# frozen_string_literal: true

require 'delegate'

module HamlLint
  # A thin wrapper around the syntax tree from the Parser gem.
  class ParsedRuby < SimpleDelegator
    # !@method syntax_tree
    #   Returns the bare syntax tree from the wrapper.
    #
    #   @api semipublic
    #   @return [Array] syntax tree in the form returned by Parser gem
    alias syntax_tree __getobj__

    # Checks whether the syntax tree contains any instance variables.
    #
    # @return [true, false]
    def contains_instance_variables?
      return false unless syntax_tree

      syntax_tree.ivar_type? || syntax_tree.each_descendant.any?(&:ivar_type?)
    end

    # Checks whether the syntax tree contains any plain text.
    #
    # @return [true, false]
    def contains_plain_text?
      return false unless syntax_tree

      plain_text? || syntax_tree.each_descendant.any? do |descendant|
        ParsedRuby.new(descendant).contains_plain_text?
      end
    end

    def plain_text?
      string? && !param_string?
    end

    def string?
      syntax_tree.str_type? && alphabetic?
    end

    def alphabetic?
      ALPHABETIC =~ syntax_tree.source
    end

    def param?
      parent_node = syntax_tree.parent
      return false unless parent_node

      parent_node.send_type? || parent_node.pair_type?
    end
  end
end
