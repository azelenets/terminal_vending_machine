# frozen_string_literal: true

require 'terminal-table'
require 'tty-box'
require 'pry'
require_relative 'application_window'
require_relative 'product'
require_relative 'coin_holder'

module RubyVendingMachine
  class Application
    attr_accessor :products, :coin_holder

    def initialize(products:, coins:)
      @products = products.map do |product_attrs|
        ::RubyVendingMachine::Product.new(product_attrs)
      end
      @coin_holder = ::RubyVendingMachine::CoinHolder.new(coins)
    end

    def run
      application_window = ApplicationWindow.new(self)
      application_window.display_available_products

      until @application_exit do
        @application_exit = application_window.display_main_menu
      end
    end
  end
end