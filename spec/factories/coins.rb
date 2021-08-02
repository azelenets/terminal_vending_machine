# frozen_string_literal: true

FactoryBot.define do
  factory :coin, class: RubyVendingMachine::Coin do
    initialize_with { new(attributes) }

    amount { 25 }
    quantity { 1 }
  end
end
