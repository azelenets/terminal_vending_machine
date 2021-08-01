# frozen_string_literal: true

module RubyVendingMachine
  # class to describe real world Product
  class Product
    attr_reader :name, :price_cents
    attr_accessor :quantity

    def initialize(name:, price_cents:, quantity: 1)
      @name = name
      @price_cents = price_cents
      @quantity = quantity
    end

    def price_dollars
      price_cents / 100.0
    end

    def to_s
      "#{name} (#{price_cents / 100.0}$ x #{quantity})"
    end
  end
end
