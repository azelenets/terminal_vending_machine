# frozen_string_literal: true

require_relative 'coin'

module RubyVendingMachine
  # class to describe real world CoinHopper
  class CoinHopper
    attr_reader :coins

    def initialize(coins_json)
      @coins = coins_json.map do |coin_json|
        ::RubyVendingMachine::Coin.new(amount: coin_json[:amount], quantity: 0)
      end
    end

    def insert_coin(coin)
      coin = coins.find { |valid_coin| valid_coin.amount == coin.amount }
      coin.quantity += 1
    end

    def inserted_coins
      @coins.select { |coin| coin.quantity.positive? }
    end

    def release_coins
      released_coins = inserted_coins.map(&:dup)
      coins.each { |coin| coin.quantity = 0 }
      released_coins
    end

    def inserted_cents_amount
      @coins.sum { |coin| coin.amount * coin.quantity }
    end

    def as_json
      {
        coins: coins.map(&:as_json)
      }
    end
  end
end
