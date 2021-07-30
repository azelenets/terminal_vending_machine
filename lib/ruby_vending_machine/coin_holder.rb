# frozen_string_literal: true

require_relative 'coin'

module RubyVendingMachine
  class CoinHolder
    attr_reader :available_coins

    def initialize(coins)
      @available_coins = coins.map { |coin_json| ::RubyVendingMachine::Coin.new(coin_json) }
    end

    def to_s
      available_coins.map { |coin| "#{coin.quantity} Coins with amount #{coin.amount}" }.join("\n")
    end
  end
end