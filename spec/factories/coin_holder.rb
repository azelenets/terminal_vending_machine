# frozen_string_literal: true

FactoryBot.define do
  factory :coin_holder, class: RubyVendingMachine::CoinHolder do
    initialize_with { new(coins_json) }
    
    transient do
      coins_json do
        [25, 50, 100, 200, 300, 500].map do |amount|
          attributes_for(:coin, amount: amount)
        end
      end
    end
  end
end
