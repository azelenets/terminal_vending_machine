# frozen_string_literal: true

require 'terminal-table'
require 'tty-box'
require 'tty-prompt'

module RubyVendingMachine
  # class to write messages in terminal
  class TerminalWriter
    def initialize
      @terminal_prompt = TTY::Prompt.new
    end

    def display_select_menu(title, options)
      terminal_prompt.select(
        title.yellow.underline,
        filter: true, per_page: 10
      ) do |menu|
        options.map do |menu_option|
          menu.choice(menu_option[:name], menu_option[:handler])
        end
      end
    end

    def display_yesno_menu(title, yes_handler, no_handler)
      if terminal_prompt.yes?(title)
        yes_handler.call
      else
        no_handler.call
      end
    end

    def display_box(box_type, message, options = {})
      product_purchase_box = TTY::Box.send(box_type, message, options)
      print "\n#{product_purchase_box}\n"
      sleep(1)
    end

    def display_table(title:, headings:, rows:)
      table = Terminal::Table.new(
        title: title,
        headings: headings,
        rows: rows
      )
      puts "#{table}\n".green
    end

    private

    attr_reader :terminal_prompt
  end
end
