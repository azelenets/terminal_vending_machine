# frozen_string_literal: true

FactoryBot.define do
  factory :coin,
          class: RubyVendingMachine::Coin,
          aliases: %i[quarter_dollar_coin] do
    initialize_with { new(attributes) }

    amount { 25 }
    quantity { 1 }

    trait :half_dollar do
      amount { 50 }
      quantity { 1 }
    end

    trait :one_dollar do
      amount { 100 }
      quantity { 1 }
    end

    trait :two_dollar do
      amount { 200 }
      quantity { 1 }
    end

    trait :three_dollar do
      amount { 300 }
      quantity { 1 }
    end

    trait :five_dollar do
      amount { 500 }
      quantity { 1 }
    end

    factory :half_dollar_coin, traits: %i[half_dollar]
    factory :one_dollar_coin, traits: %i[one_dollar]
    factory :two_dollar_coin, traits: %i[two_dollar]
    factory :three_dollar_coin, traits: %i[three_dollar]
    factory :five_dollar_coin, traits: %i[five_dollar]
  end
end
