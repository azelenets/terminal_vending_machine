# frozen_string_literal: true

require_relative 'coin'

module RubyVendingMachine
  class CoinHolder
    attr_reader :coins

    def initialize(coins)
      @coins = coins.map { |coin_json| ::RubyVendingMachine::Coin.new(coin_json) }
    end

    def dispense_change(cents:)
      # coins = change_to_coins(change_cents: cents)
      coins = make_change(cents)
      coins.nil? ? nil : coins
    end

    private

    def change_to_coins(change_cents:)
      change_coins = []
      remaining_change = change_cents.dup

      sorted_coins = coins.sort { |coin| -coin.amount }
      sorted_coins.each_with_index do |coin, index|
        next if coin.amount > remaining_change

        coin_in_change = change_coins.find { |change_coin| change_coin.amount == coin.amount }
        needed_quantity, remainder = remaining_change.divmod(coin.amount)

        if needed_quantity > coin.quantity
          if coin_in_change
            coin_in_change.quantity = coin.quantity
          else
            coin_in_change = coin.dup
            change_coins << coin_in_change
          end

          coin = sorted_coins[index + 1]
          needed_quantity, remainder = remaining_change.divmod(coin.amount)

          binding.pry

          next if coin.amount > remaining_change || needed_quantity > coin.quantity

          coin_in_change = change_coins.find { |change_coin| change_coin.amount == coin.amount }
          needed_quantity, remainder = remaining_change.divmod(coin.amount)
        end

        if needed_quantity.positive? && coin.quantity.positive?
          if coin_in_change
            coin_in_change.quantity += 1
          else
            coin_in_change = coin.dup
            coin_in_change.quantity = 1
            change_coins << coin_in_change
          end
        end

        remaining_change = remainder.round(2)

        break if remaining_change.zero?
      end

      remaining_change.zero? ? change_coins : nil
    end

    def make_change(amount)
      coins_to_release = []

      coins
        .sort { |coin| -coin.amount }
        .each do |coin|
          # next if amount.zero?

          needed_coins_quantity = amount / coin.amount
          release_coin = coins_to_release.find { |rc| rc.amount == coin.amount }

          if release_coin.nil?
            release_coin = Coin.new(amount: coin.amount)
            coins_to_release << release_coin
          end

          if needed_coins_quantity > coin.quantity
            release_coin.quantity = 0
          else
            release_coin.quantity = needed_coins_quantity
          end

          next if release_coin.quantity.zero?

          amount -= release_coin.amount * release_coin.quantity
      end

      if amount > 0
        next_change_result = make_change(amount)
        next_change_result.each do |next_change_coin|
          release_coin = coins_to_release.find { |rc| rc.amount == next_change_coin.amount } || (coins_to_release << next_change_coin.dup).last
          release_coin.quantity += next_change_coin.quantity
        end
      end

      coins_to_release.filter! { |coin| coin.quantity > 0 }
    end

    def total_cents_amount
      coins.sum { |coin| coin.amount * coin.quantity }
    end

    def to_s
      coins.map { |coin| "#{coin.quantity} Coins with amount #{coin.amount}" }.join("\n")
    end
  end
end