# frozen_string_literal: true

require_relative 'terminal_output'

module RubyVendingMachine
  class ApplicationWindow
    def initialize(application)
      @application = application
      @terminal_output = TerminalOutput.new
    end

    def show_main_menu
      prompt_options = [
        Hash[name: 'Show Products',
             handler: -> do
               display_products_table(application.products)
               show_main_menu
             end],
        Hash[name: 'Buy Product',
             handler: -> { show_buy_product_menu }],
        Hash[name: 'Show CoinsHolder (debug mode)',
             handler: -> { display_coins_holder(application.coin_holder) }],
        Hash[name: 'Exit application', handler: -> { true }]
      ]

      terminal_output.display_select_menu('Choose an action', prompt_options)
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

    def display_coins_holder(coins_holder)
      terminal_output.display_table(
        title: 'COINS HOLDER',
        headings: ['Amount, $', 'Quantity'],
        rows: coins_holder.coins.map do |coin|
          [coin.dollar_amount, coin.quantity]
        end
      )
    end

    def handle_product_selection(product)
      application.select_product_to_buy(product)

      if product.quantity.zero?
        terminal_output.display_box(
          :error,
          "#{product.name} out of stock",
          { title: { top_left: " ✘ OUT OF STOCK " } }
        )
        show_buy_product_menu
      end

      insert_coins_menu
    end

    def insert_coins_menu
      inserted_coins = application.coin_hopper.inserted_coins.map do |coin|
        "#{coin.quantity} x #{coin.dollar_amount}$"
      end.join("\n")

      prompt_options = application.coin_hopper.coins.map do |coin|
        {
          name: "Insert #{coin.dollar_amount}$",
          handler: -> { handle_insert_coin(coin) }
        }
      end
      prompt_options << {
        name: "Back",
        handler: -> do
          show_buy_product_menu if application.coin_hopper.inserted_coins.sum(&:quantity) == 0

          terminal_output.display_yesno_menu(
            'Are you sure? It will cause inserted coins release.'.red,
            -> do
              released_coins = application.coin_hopper.release_coins
              if released_coins.sum(&:quantity) > 0
                terminal_output.display_box(
                  :warn,
                  "Take back your #{released_coins.map(&:to_s).join(", ")}",
                  { title: { top_left: " ✔ RELEASED " } }
                )
              end
              show_main_menu
            end,
            -> { insert_coins_menu }
          )
        end
      }

      terminal_output.display_select_menu(
        "Please insert coins into coins hopper.\n"\
        "Coins inserted:\n#{inserted_coins}",
        prompt_options
      )
    end

    def handle_insert_coin(coin)
      application.coin_hopper.insert_coin(coin)

      terminal_output.display_box(
        :info,
        "1 x #{coin.dollar_amount}$ received.\n"\
          "Now your balance #{application.coin_hopper.inserted_cents_amount / 100.0}$",
        { title: { top_left: " ✔ COINS RECEIVED: " } }
      )

      seller_response = application.sell_selected_product
      case seller_response[:message]
      when :large_mount_needed then
        residual_payment_amount = seller_response.dig(:data, :amount)

        terminal_output.display_box(
          :info,
          "Please add #{residual_payment_amount / 100.0}$ using coins:\n" +
          CoinHopper::VALID_COIN_AMOUNT.map { |coin_amount| "  - #{coin_amount / 100.0}$" }.join("\n") +
          "Your current balance: #{application.coin_hopper.inserted_cents_amount / 100.0}$",
          { title: { top_left: ' ✔ BALANCE: ' } }
        )
        insert_coins_menu
      when :success
        product = seller_response.dig(:data, :product)
        change_coins = seller_response.dig(:data, :change_coins)

        message = ""
        message += "1 x #{product.name} (#{product.price_dollars}$)" if product
        unless change_coins.nil?
          message += "\nDon't forget to take #{change_coins.sum { |change_coin| change_coin.amount / 100.0 }}$:\n" +
            change_coins.map { |change_coin| "  - #{change_coin.quantity} x #{change_coin.amount / 100.0}$" }.join("\n")
        end

        terminal_output.display_box(:success, message, { title: { top_left: " ✔ PURCHASED " } })
      when :no_change
        released_coins = seller_response.dig(:data, :released_coins)
        terminal_output.display_box(
          :error,
          "Sorry, but no change.\nTake back your #{released_coins.map(&:to_s).join(", ")}",
          { title: { top_left: " ✘ NO CHANGE | RELEASED " } }
        )
      else
        terminal_output.display_box(
          :error,
          seller_response[:data],
          { title: { top_left: " ✘ ERROR " } }
        )
      end

      show_main_menu
    end

    def show_buy_product_menu
      display_products_table(application.products)

      prompt_options = application.products.map.with_index do |product, index|
        {
          name: "#{index + 1}. Buy #{product.name} - #{product.price_dollars}$"
                  .send(product.quantity.zero? ? :red : :green),
          handler: -> { handle_product_selection(product) }
        }
      end
      prompt_options << { name: 'Go to Main Menu', handler: -> { show_main_menu } }

      terminal_output.display_select_menu('Please select a product', prompt_options)
    end

    private

    attr_reader :application, :terminal_output
  end
end