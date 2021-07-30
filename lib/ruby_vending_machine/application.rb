# frozen_string_literal: true

require_relative 'product'
require 'terminal-table'
require 'tty-box'

module RubyVendingMachine
  class Application
    attr_accessor :terminal_prompt, :products

    def initialize(products:)
      @terminal_prompt = TTY::Prompt.new
      @products = products.map do |product_attrs|
        ::RubyVendingMachine::Product.new(product_attrs)
      end
    end

    def run
      system 'clear'
      display_available_products

      until @application_exit do
        display_main_menu
      end
    end

    private

    def display_main_menu
      terminal_prompt.select('Choose an action'.yellow.underline, filter: true, per_page: 10) do |menu|
        menu.choice 'Show Products', -> { display_available_products; display_main_menu; }
        menu.choice 'Buy Product',  -> { select_product }
        menu.choice 'Exit application',  -> { @application_exit = true }
      end
    end

    def select_product
      terminal_prompt.select('Please select a product'.yellow.underline, filter: true, per_page: 10) do |menu|
        products.each_with_index do |product, index|
          menu.choice(
            "#{index + 1}. Buy #{product.to_s}"
              .send(product.quantity.zero? ? :red : :green),
            -> { buy_product_menu(product) }
          )
        end
        menu.choice 'Go to Main Menu',  -> { display_main_menu }
      end
    end

    def display_available_products
      rows = products.map { |product| [product.name, product.price_cents / 100, product.quantity] }
      table = Terminal::Table.new(
        title: 'Vending Machine loaded with next Products:',
        headings: ['Name', 'Price, $', 'Quantity'],
        rows: rows
      )
      puts table.to_s.green
    end

    def buy_product_menu(product)
      if product.quantity.zero?
        error_box = TTY::Box.error("#{product.name} out of stock")
        print error_box

        select_product
      else
        product.quantity = product.quantity - 1

        success_box = TTY::Box.success("#{product.name} purchased")
        print success_box
      end
    end
  end
end