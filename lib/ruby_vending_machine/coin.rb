# frozen_string_literal: true

module RubyVendingMachine
  # class to describe real world Coin
  class Coin
    attr_reader :amount
    attr_accessor :quantity

    def initialize(amount:, quantity: 1)
      @amount = amount
      @quantity = quantity
    end

    def dollar_amount
      amount / 100.0
    end

    def to_s
      "#{quantity} x #{dollar_amount}$ #{quantity == 1 ? 'coin' : 'coins'}"
    end
  end
end
