# frozen_string_literal: true

module RubyVendingMachine
  class Product
    attr_reader :name, :price_cents
    attr_accessor :quantity

    def initialize(name:, price_cents:, quantity: 1)
      @name = name
      @price_cents = price_cents
      @quantity = quantity
    end

    def to_s
      "#{name} (#{price_cents / 100.0}$ x #{quantity})"
    end
  end
end