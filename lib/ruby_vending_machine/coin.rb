# frozen_string_literal: true

module RubyVendingMachine
  class Coin
    attr_reader :amount
    attr_accessor :quantity

    def initialize(amount:, quantity: 1)
      @amount = amount
      @quantity = quantity
    end

    def to_s
      "#{quantity} #{name} Coins with amount "
    end
  end
end