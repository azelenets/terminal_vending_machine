# frozen_string_literal: true

require_relative 'coin'

module RubyVendingMachine
  class CoinHopper
    VALID_COIN_AMOUNT = [25, 50, 100, 200, 300, 500].freeze

    attr_reader :coins

    def initialize
      @coins = VALID_COIN_AMOUNT.map { |coin_amount| ::RubyVendingMachine::Coin.new(amount: coin_amount, quantity: 0) }
    end

    def insert_coin(coin)
      coin = coins.find { |valid_coin| valid_coin.amount == coin.amount }
      coin.quantity += 1
    end

    def inserted_coins
      @coins.select { |coin| coin.quantity > 0 }
    end

    def release_coins
      released_coins = inserted_coins.map { |coin| coin.dup }
      inserted_coins.each { |coin| coin.quantity = 0 }
      released_coins
    end

    def total_cents
      @coins.sum { |coin| coin.amount * coin.quantity }
    end
  end
end