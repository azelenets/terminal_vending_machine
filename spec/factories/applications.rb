# frozen_string_literal: true

FactoryBot.define do
  factory :application, class: RubyVendingMachine::Application do
    initialize_with { new(attributes) }

    coins do
      [
        attributes_for(:quarter_dollar_coin),
        attributes_for(:half_dollar_coin),
        attributes_for(:one_dollar_coin),
        attributes_for(:two_dollar_coin),
        attributes_for(:three_dollar_coin),
        attributes_for(:five_dollar_coin)
      ]
    end
    products do
      [
        attributes_for(:crisps_product),
        attributes_for(:chocolate_product),
        attributes_for(:water_product),
        attributes_for(:coca_cola_product)
      ]
    end
  end
end
