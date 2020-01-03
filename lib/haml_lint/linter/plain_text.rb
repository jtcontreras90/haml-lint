# frozen_string_literal: true

module HamlLint
  # Detects plain text in a view
  class Linter::PlainText < Linter
    include LinterRegistry

    MESSAGE_FORMAT = %{`%s` should be translated}.freeze

    # Checks for plain text in script nodes
    #
    # @param [HamlLint::Tree:ScriptNode]
    # @return [void]
    def visit_script(node)
      check_script(node)
    end


    # Checks for plain text in tag nodes
    #
    # @param [HamlLint::Tree:TagNode]
    # @return [void]
    def visit_tag(node)
      visit_script(node) ||
        if node.script.length.positive?
          add_lint(node, text)
        end

      check_tag_value(node)
    end


    # Checks for plain text in plain nodes
    #
    # @param [HamlLint::Tree:PlainNode]
    # @return [void]
    def visit_plain(node)
      return unless alphabetic?(node.text.strip) &&
                    !special_html?(node.text.strip)

      record(node, node.text.strip)
    end

    private

    def add_lint(node, text)
      record_lint(node, MESSAGE_FORMAT % text)
    end
  end
end
