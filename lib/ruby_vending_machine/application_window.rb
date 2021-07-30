# frozen_string_literal: true

module RubyVendingMachine
  class ApplicationWindow
    attr_reader :terminal_prompt, :application

    def initialize(application)
      @terminal_prompt = TTY::Prompt.new
      @application = application
    end

    def display_main_menu
      terminal_prompt.select('Choose an action'.yellow.underline) do |menu|
        menu.choice(
          'Show Products',
          -> {
            display_available_products
            display_main_menu
          }
        )
        menu.choice 'Buy Product',  -> { select_product }
        menu.choice 'Show Coins',  -> { display_available_coins }
        menu.choice 'Exit application',  -> { true }
      end
    end

    def display_available_products
      rows = application.products.map do |product|
        [product.name, product.price_cents / 100.0, product.quantity]
      end
      table = Terminal::Table.new(
        title: 'Vending Machine loaded with next Products:',
        headings: ['Name', 'Price, $', 'Quantity'],
        rows: rows
      )

      system 'clear'
      puts table.to_s.green
    end

    def display_available_coins
      rows = application.coin_holder.available_coins.map do |coin|
        [coin.amount / 100.0, coin.quantity]
      end
      table = Terminal::Table.new(
        title: 'COINS',
        headings: ['Amount, $', 'Quantity'],
        rows: rows
      )

      system 'clear'
      puts table.to_s.green
    end

    def handle_product_purchase(product)
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

    def select_product
      display_available_products

      terminal_prompt.select('Please select a product'.yellow.underline, filter: true, per_page: 10) do |menu|
        application.products.each_with_index do |product, index|
          menu.choice(
            "#{index + 1}. Buy #{product.to_s}"
              .send(product.quantity.zero? ? :red : :green),
            -> { handle_product_purchase(product) }
          )
        end
        menu.choice 'Go to Main Menu',  -> { display_main_menu }
      end
    end

  end
end