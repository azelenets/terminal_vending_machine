# frozen_string_literal: true

require_relative 'coin'

module RubyVendingMachine
  # class to describe real world CoinHolder
  class CoinHolder
    attr_reader :coins

    def initialize(coins)
      @coins = coins.map { |coin_json| ::RubyVendingMachine::Coin.new(coin_json) }
    end

    def dispense_change(cents:)
      coins = look_for_change(cents)
      coins.nil? ? nil : coins
    end

    def receive_coins(coins_to_receive)
      return if coins_to_receive.sum { |coin| coin.amount * coin.quantity } <= 0

      coins_to_receive.each do |received_coin|
        coin = coins.find { |holder_coin| received_coin.amount == holder_coin.amount }
        coin.quantity += received_coin.quantity
      end
    end

    def give_change(change_coins)
      change = change_coins.dup
      change_coins.each do |change_coin|
        coin = coins.find { |holder_coin| change_coin.amount == holder_coin.amount }
        coin.quantity -= change_coin.quantity
      end
      change.filter { |change_coin| change_coin.quantity.positive? }
    end

    def look_for_change(amount)
      coins_to_release = []
      started_amount = amount.dup
      coins.sort { |coin| -coin.amount }.each do |coin|
        needed_coins_quantity = amount / coin.amount
        release_coin = coins_to_release.find { |rc| rc.amount == coin.amount }

        if release_coin.nil?
          release_coin = Coin.new(amount: coin.amount)
          coins_to_release << release_coin
        end

        release_coin.quantity = needed_coins_quantity > coin.quantity ? 0 : needed_coins_quantity

        next if release_coin.quantity.zero?

        amount -= release_coin.amount * release_coin.quantity
      end

      return if started_amount == amount

      if amount.positive?
        next_change_result = look_for_change(amount)
        return [] if next_change_result.nil?

        next_change_result.each do |next_change_coin|
          release_coin = coins_to_release.find do |rc|
            rc.amount == next_change_coin.amount
          end || (coins_to_release << next_change_coin.dup).last
          release_coin.quantity += next_change_coin.quantity
        end
      end

      coins_to_release.filter! { |coin| coin.quantity.positive? }
    end

    def to_s
      coins.map { |coin| "#{coin.quantity} Coins with amount #{coin.amount}" }.join("\n")
    end
  end
end
