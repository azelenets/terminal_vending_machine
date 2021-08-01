# frozen_string_literal: true

require_relative 'terminal_output'

module RubyVendingMachine
  class ApplicationWindow
    def initialize(application)
      @application = application
      @terminal_output = TerminalOutput.new
    end

    def self.run(application)
      application_window = new(application)
      application_window.display_products_table(application.products)

      until @application_exit do
        @application_exit = application_window.show_main_menu
      end
    end

    def show_main_menu
      menu_actions = [
        Hash[name: 'Show Products',
             handler: -> do
               display_products_table(application.products)
               show_main_menu
             end],
        Hash[name: 'Buy Product',
             handler: -> { show_select_product_menu(application.products) }],
        Hash[name: 'Show CoinsHolder (debug mode)',
             handler: -> do
               terminal_output.display_table(
                 title: 'COINS HOLDER',
                 headings: ['Amount, $', 'Quantity'],
                 rows: application.coin_holder.coins.map do |coin|
                   [coin.dollar_amount, coin.quantity]
                 end
               )
             end],
        Hash[name: 'Exit application', handler: -> { @application_exit = true }]
      ]
      terminal_output.display_select_menu('Choose an action', menu_actions)
    end

    def display_products_table(products)
      terminal_output.display_table(
        title: 'Vending Machine products:',
        headings: ['Name', 'Price, $', 'Quantity'],
        rows: products.map do |product|
          [product.name, product.price_dollars, product.quantity]
        end
      )
    end

    def show_insert_coins_menu
      prompt_options = application.coin_hopper.coins.map do |coin|
        Hash[name: "Insert #{coin.dollar_amount}$",
             handler: -> { handle_insert_coin(coin) }]
      end
      prompt_options << {
        name: "Back",
        handler: -> do
          if application.coin_hopper.inserted_coins.sum(&:quantity) == 0
            show_select_product_menu(application.products)
          end

          terminal_output.display_yesno_menu(
            'Are you sure? It will cause inserted coins release.'.red,
            -> do
              application.select_product_to_buy(nil)
              released_coins = application.coin_hopper.release_coins
              if released_coins.sum(&:quantity) > 0
                terminal_output.display_box(
                  :warn,
                  "Take back your #{released_coins.map(&:to_s).join(", ")}",
                  Hash[title: { top_left: " ✔ RELEASED " }]
                )
              end
              show_main_menu
            end,
            -> { show_insert_coins_menu }
          )
        end
      }

      inserted_coins = application.coin_hopper.inserted_coins.map do |coin|
        "#{coin.quantity} x #{coin.dollar_amount}$"
      end.join("\n")
      terminal_output.display_select_menu(
        "Please insert coins into coins hopper.\n"\
        "Coins inserted:\n#{inserted_coins}",
        prompt_options
      )
    end

    def handle_insert_coin(coin)
      terminal_output.display_box(
        :info,
        "1 x #{coin.dollar_amount}$ received",
        Hash[title: { top_left: " ✔ COINS RECEIVED: " }]
      )
      seller_response = application.insert_coin(coin)
      case seller_response[:message]
      when :large_mount_needed then
        residual_payment_amount = seller_response.dig(:data, :amount)

        terminal_output.display_box(
          :info,
          "Please add #{residual_payment_amount.abs / 100.0}$ using coins:\n" +
          CoinHopper::VALID_COIN_AMOUNT.map { |coin_amount| "  - #{coin_amount / 100.0}$" }.join("\n") +
          "\nYour current balance: #{application.coin_hopper.inserted_cents_amount / 100.0}$",
          Hash[title: { top_left: ' ✔ BALANCE: ' }]
        )
        show_insert_coins_menu
      when :success
        product = seller_response.dig(:data, :product)
        change_coins = seller_response.dig(:data, :change_coins)

        message = ""
        message += "1 x #{product.name} (#{product.price_dollars}$)" if product
        unless change_coins.nil?
          change_amount = change_coins.sum { |change_coin| change_coin.amount / 100.0 }
          message += "\nDon't forget to take #{change_amount}$:\n" +
            change_coins.map { |change_coin| "  - #{change_coin.quantity} x #{change_coin.amount / 100.0}$" }.join("\n")
        end

        terminal_output.display_box(
          :success,
          message,
          Hash[title: { top_left: " ✔ PURCHASED " }]
        )
        show_main_menu
      when :no_change
        released_coins = seller_response.dig(:data, :released_coins)
        terminal_output.display_box(
          :error,
          "Sorry, but no change.\nTake back your #{released_coins.map(&:to_s).join(", ")}",
          Hash[title: { top_left: " ✘ NO CHANGE | RELEASED " }]
        )
        show_main_menu
      else
        terminal_output.display_box(
          :error,
          seller_response[:data],
          Hash[title: { top_left: " ✘ ERROR " }]
        )
        show_main_menu
      end
    end

    def show_select_product_menu(products)
      prompt_options = products.map.with_index do |product, index|
        {
          name: "#{index + 1}. Buy #{product.name} - #{product.price_dollars}$"
                  .send(product.quantity.zero? ? :red : :green),
          handler: -> do
            if product.quantity.zero?
              application.select_product_to_buy(nil)
              terminal_output.display_box(
                :error,
                "#{product.name} out of stock",
                Hash[title: { top_left: " ✘ OUT OF STOCK " }]
              )
              show_select_product_menu(application.products)
            end

            application.select_product_to_buy(product)
            show_insert_coins_menu
          end
        }
      end
      prompt_options << { name: 'Go to Main Menu', handler: -> { show_main_menu } }

      terminal_output.display_select_menu('Please select a product', prompt_options)
    end

    private

    attr_reader :application, :terminal_output
  end
end