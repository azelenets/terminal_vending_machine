# frozen_string_literal: true

module RubyVendingMachine
  class ApplicationWindow
    attr_reader :terminal_prompt, :application

    def initialize(application)
      @terminal_prompt = TTY::Prompt.new
      @application = application
    end

    def show_main_menu
      terminal_prompt.select('Choose an action'.yellow.underline) do |menu|
        menu.choice(
          'Show Products',
          -> {
            display_available_products
            show_main_menu
          }
        )
        menu.choice 'Buy Product',  -> { show_buy_product_menu }
        menu.choice 'Show CoinsHolder (debug mode)',  -> { display_coins_holder }
        menu.choice 'Exit application',  -> { true }
      end
    end

    def display_available_products
      rows = application.products.map do |product|
        [product.name, product.price_dollars, product.quantity]
      end
      table = Terminal::Table.new(
        title: 'Vending Machine products:',
        headings: ['Name', 'Price, $', 'Quantity'],
        rows: rows
      )

      system 'clear'
      puts table.to_s.green
    end

    def display_coins_holder
      rows = application.coin_holder.coins.map do |coin|
        [coin.dollar_amount, coin.quantity]
      end
      table = Terminal::Table.new(
        title: 'COINS',
        headings: ['Amount, $', 'Quantity'],
        rows: rows
      )

      system 'clear'
      puts table.to_s.green
    end

    def handle_product_selection(product)
      application.selected_product = product

      if product.quantity.zero?
        error_box = TTY::Box.error("#{product.name} out of stock")
        print error_box

        show_buy_product_menu
        return
      end

      insert_coins_menu
    end

    def insert_coins_menu
      inserted_coins = application.coin_hopper.inserted_coins.map do |coin|
        "#{coin.quantity} x #{coin.dollar_amount}$"
      end.join("\n")
      terminal_prompt.select(
        "Please insert coins into coins hopper.\nCoins inserted: #{inserted_coins}".yellow.underline,
        filter: true, per_page: 10
      ) do |menu|
        application.coin_hopper.coins.each do |coin|
          menu.choice "Insert #{coin.dollar_amount}$",  -> { insert_coin(coin) }
        end
        menu.choice 'Back',  -> {
          if terminal_prompt.yes?('Are you sure? It will cause inserted coins release.'.red)
            released_coins = application.coin_hopper.release_coins
            if released_coins.size > 0
              success_message = released_coins.map { |coin| coin.to_s }.join("\n")
              error_box = TTY::Box.success(success_message)
              print error_box
              sleep(2)
            end

            show_buy_product_menu
          else
            insert_coins_menu
          end
        }
      end
    end

    def insert_coin(coin)
      application.coin_hopper.insert_coin(coin)
      change = application.coin_hopper.total_cents - application.selected_product.price_cents

      if change < 0
        insert_coins_menu
      else
        if change.zero?
          # Stock needs to dispense the Product

          application.selected_product.quantity = application.selected_product.quantity - 1
          product_purchase_box = TTY::Box.success("#{application.selected_product.name} purchased")
          print product_purchase_box
          sleep(3)
        else
          # binding.pry

          change_in_coins = application.coin_holder.dispense_change(cents: change)
          application.coin_hopper.release_coins

          if change_in_coins.nil?
            product_purchase_box = TTY::Box.error("Sorry, but no change. Take back your coins and try luck!")
            print product_purchase_box
            sleep(3)
          else
            # Stock needs to dispense the product
            application.selected_product.quantity = application.selected_product.quantity - 1

            product_purchase_box = TTY::Box.success("#{application.selected_product.name} purchased")
            print product_purchase_box

            change_box = TTY::Box.success("Don't forget to take #{change_in_coins.map(&:to_s).join(', ')}!")
            print change_box
            sleep(3)
          end
        end

        show_main_menu
      end
    end

    def handle_product_purchase

    end

    def show_buy_product_menu
      display_available_products

      terminal_prompt.select(
        'Please select a product'.yellow.underline,
        filter: true, per_page: 10
      ) do |menu|
        application.products.each_with_index do |product, index|
          menu.choice(
            "#{index + 1}. Buy #{product.name} (#{product.price_dollars})"
              .send(product.quantity.zero? ? :red : :green),
            -> { handle_product_selection(product) }
          )
        end
        menu.choice 'Go to Main Menu',  -> { show_main_menu }
      end
    end

  end
end