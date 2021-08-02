# frozen_string_literal: true

RSpec.describe RubyVendingMachine::Coin do
  subject(:coin) { build(:coin, amount: coin_amount, quantity: coin_quantity) }

  let(:coin_amount) { 25 }
  let(:coin_quantity) { 1 }

  it { is_expected.to have_attributes(amount: coin_amount, quantity: coin_quantity) }

  describe '#dollar_amount' do
    subject { coin.dollar_amount }

    it { is_expected.to eq(coin_amount / 100.0) }
  end

  describe '#to_s' do
    subject { coin.to_s }

    it do
      is_expected.to eq("#{coin.quantity} x #{coin.dollar_amount}$ coin")
    end

    context 'when quantity > 1' do
      let(:coin_quantity) { 2 }

      it do
        is_expected.to eq("#{coin.quantity} x #{coin.dollar_amount}$ coins")
      end
    end
  end
end
