# frozen_string_literal: true

FactoryBot.define do
  factory :product,
          class: RubyVendingMachine::Product,
          aliases: %i[crisps_product] do
    initialize_with { new(attributes) }

    name { 'Crisps' }
    price_cents { 75 }
    quantity { 1 }

    trait :chocolate do
      name { 'Chocolate' }
      price_cents { 150 }
    end

    trait :water do
      name { 'Water' }
      price_cents { 75 }
    end

    trait :coca_cola do
      name { 'Coca-Cola' }
      price_cents { 75 }
    end

    factory :chocolate_product, traits: %i[chocolate]
    factory :water_product, traits: %i[water]
    factory :coca_cola_product, traits: %i[coca_cola]
  end
end
