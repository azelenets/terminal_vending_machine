# frozen_string_literal: true


require 'pry'
require_relative 'application_window'
require_relative 'product'
require_relative 'coin_holder'
require_relative 'coin_hopper'

module RubyVendingMachine
  class Application
    # TODO: hide initialized_attributes into "private" scope
    # and make available only methods() that uses this attrs
    attr_accessor :products, :selected_product,
                  :coin_hopper, :coin_holder

    def initialize(products:, coins:)
      @products = products.map do |product_attrs|
        ::RubyVendingMachine::Product.new(product_attrs)
      end
      @selected_product = nil
      @coin_hopper = ::RubyVendingMachine::CoinHopper.new
      @coin_holder = ::RubyVendingMachine::CoinHolder.new(coins)
    end

    def run
      application_window = ApplicationWindow.new(self)
      application_window.display_products_table(products)

      until @application_exit do
        @application_exit = application_window.show_main_menu
      end
    end

    def select_product_to_buy(product)
      self.selected_product = product
    end

    def dispense_selected_product
      return if self.selected_product.nil?

      product = self.selected_product.dup
      self.selected_product.quantity -= 1
      self.selected_product = nil
      product
    end

    def calculate_change
      return if selected_product.nil?

      coin_hopper.inserted_cents_amount - selected_product.price_cents
    end

    def sell_selected_product
      overpayment = calculate_change
      return { message: :large_mount_needed, data: { amount: overpayment } } if overpayment < 0

      if overpayment.zero?
        released_coins = coin_hopper.release_coins
        coin_holder.receive_coins(released_coins)
        product = dispense_selected_product

        return { message: :success, data: { product: product } }
      end

      change_in_coins = coin_holder.look_for_change(overpayment)
      if change_in_coins.nil?
        released_coins = coin_hopper.release_coins
        return { message: :no_change, data: Hash[released_coins: released_coins] }
      end

      released_coins = coin_hopper.release_coins
      coin_holder.receive_coins(released_coins)
      change_coins = coin_holder.give_change(change_in_coins)
      product = dispense_selected_product

      return { message: :error, data: 'Unhandled exception' } unless product
      return { message: :success, data: { product: product } } if change_coins.size == 0
      {
        message: :success,
        data: Hash[product: product, change_coins: change_coins]
      }
    end
  end
end