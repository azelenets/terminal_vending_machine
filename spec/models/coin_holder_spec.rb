# frozen_string_literal: true

RSpec.describe RubyVendingMachine::Coin do
  subject(:coin_holder) { build(:coin_holder) }

  it { is_expected.to have_attributes(coins: coin_holder.coins) }

  describe '#receive_coins' do
    subject { coin_holder.receive_coins([coin]) }

    let(:coin) { build(:coin) }
    let(:holder_coin) do
      coin_holder.coins.find { |holder_coin| holder_coin.amount == coin.amount }
    end

    it do
      expect { subject }.to change(holder_coin, :quantity).by(1)
    end
  end
end
