# frozen_string_literal: true

RSpec.describe RubyVendingMachine::Product do
  subject(:product) do
    build(:product, name: name, price_cents: price_cents, quantity: quantity)
  end

  let(:name) { 'Test Product' }
  let(:price_cents) { 150 }
  let(:quantity) { 1 }

  it do
    is_expected.to(
      have_attributes(
        name: name,
        price_cents: price_cents,
        quantity: quantity
      )
    )
  end

  describe '#price_dollars' do
    subject { product.price_dollars }

    it { is_expected.to eq(price_cents / 100.0) }
  end

  describe '#to_s' do
    subject { product.to_s }

    it { is_expected.to eq("#{name} (#{product.price_dollars}$ x #{quantity})") }
  end
end
