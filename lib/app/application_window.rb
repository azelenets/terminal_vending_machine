# frozen_string_literal: true

require_relative 'terminal_writer'

module RubyVendingMachine
  # class to describe Application Window in Terminal
  class ApplicationWindow
    def initialize(application)
      @application = application
      @terminal_writer = TerminalWriter.new
    end

    def self.run(application)
      application_window = new(application)
      application_window.display_products_table(application.stock)

      until @application_exit
        @application_exit = application_window.show_main_menu
      end
    end

    def show_main_menu
      menu_actions = [
        Hash[name: 'Show Products',
             handler: lambda do
               display_products_table(application.stock)
               show_main_menu
             end],
        Hash[name: 'Buy Product',
             handler: -> { show_select_product_menu(application.stock) }],
        Hash[name: 'Show CoinsHolder (debug mode)',
             handler: lambda do
               terminal_writer.display_table(
                 title: 'COINS HOLDER',
                 headings: ['Amount, $', 'Quantity'],
                 rows: application.coin_holder.coins.map do |coin|
                   [coin.dollar_amount, coin.quantity]
                 end
               )
             end],
        Hash[name: 'Exit application', handler: -> { @application_exit = true }]
      ]
      terminal_writer.display_select_menu('Choose an action', menu_actions)
    end

    def display_products_table(products)
      terminal_writer.display_table(
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
        name: 'Back',
        handler: lambda do
          application.coin_hopper.inserted_coins.sum(&:quantity).zero? &&
            show_select_product_menu(application.stock)

          terminal_writer.display_yesno_menu(
            'Are you sure? It will cause inserted coins release.'.red,
            lambda do
              application.select_product_to_buy(nil)
              released_coins = application.coin_hopper.release_coins
              if released_coins.sum(&:quantity).positive?
                terminal_writer.display_box(
                  :warn,
                  "Take back your #{released_coins.map(&:to_s).join(', ')}",
                  Hash[title: { top_left: ' ??? RELEASED ' }]
                )
              end
              show_main_menu
            end,
            -> { show_insert_coins_menu }
          )
        end
      }

      inserted_coins = display_coins_amount(application.coin_hopper.inserted_coins)
      terminal_writer.display_select_menu(
        "Please insert coins into coins hopper.\n"\
        "Coins inserted:\n#{inserted_coins}",
        prompt_options
      )
    end

    def handle_insert_coin(coin)
      terminal_writer.display_box(
        :info,
        "1 x #{coin.dollar_amount}$ received",
        Hash[title: { top_left: ' ??? COINS RECEIVED: ' }]
      )
      seller_response = application.insert_coin(coin)
      case seller_response[:message]
      when :large_mount_needed
        residual_payment_amount = seller_response.dig(:data, :amount)

        terminal_writer.display_box(
          :info,
          "Please add #{residual_payment_amount.abs / 100.0}$"\
          "\nYour current balance: #{application.coin_hopper.inserted_cents_amount / 100.0}$",
          Hash[title: { top_left: ' ??? BALANCE: ' }]
        )
        show_insert_coins_menu
      when :success
        product = seller_response.fetch(:data).fetch(:product)
        received_coins = seller_response.fetch(:data).fetch(:received_coins)
        change_coins = seller_response.dig(:data, :change_coins)

        message = "Received: #{received_coins.sum { |received_coin| received_coin.dollar_amount * received_coin.quantity }}$\n" +
          display_coins_amount(received_coins) +
          "\nProduct: #{product.name}: #{product.price_dollars}$"

        unless change_coins.nil?
          change_amount = change_coins.sum { |received_coin| received_coin.dollar_amount * received_coin.quantity }
          message += "\nChange: #{change_amount}$\n" +
            display_coins_amount(change_coins)
        end

        terminal_writer.display_box(
          :success,
          message,
          Hash[title: { top_left: ' ??? PURCHASE RECEIPT ' }]
        )
        show_main_menu
      when :no_change
        released_coins = seller_response.dig(:data, :released_coins)
        terminal_writer.display_box(
          :error,
          "Sorry, but no change.\nTake back your #{released_coins.map(&:to_s).join(', ')}",
          Hash[title: { top_left: ' ??? NO CHANGE | RELEASED ' }]
        )
        show_main_menu
      else
        terminal_writer.display_box(
          :error,
          seller_response[:data],
          Hash[title: { top_left: ' ??? ERROR ' }]
        )
        show_main_menu
      end
    end

    def show_select_product_menu(products)
      prompt_options = products.map.with_index do |product, index|
        {
          name: "#{index + 1}. Buy #{product.name} - #{product.price_dollars}$"
            .send(product.quantity.zero? ? :red : :green),
          handler: lambda do
            if product.quantity.zero?
              application.select_product_to_buy(nil)
              terminal_writer.display_box(
                :error,
                "#{product.name} out of stock",
                Hash[title: { top_left: ' ??? OUT OF STOCK ' }]
              )
              show_select_product_menu(application.stock)
            end

            application.select_product_to_buy(product)
            show_insert_coins_menu
          end
        }
      end
      prompt_options << { name: 'Go to Main Menu', handler: -> { show_main_menu } }

      terminal_writer.display_select_menu('Please select a product', prompt_options)
    end

    private

    attr_reader :application, :terminal_writer

    def display_coins_amount(coins)
      coins.map { |coin| "  - #{coin.quantity} x #{coin.dollar_amount}$" }.join("\n")
    end
  end
end
