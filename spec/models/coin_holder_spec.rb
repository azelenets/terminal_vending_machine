# frozen_string_literal: true

RSpec.describe RubyVendingMachine::CoinHolder do
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

  describe '#give_change' do
    subject { coin_holder.give_change([coin]) }

    let(:coin) { build(:coin) }
    let(:holder_coin) do
      coin_holder.coins.find { |holder_coin| holder_coin.amount == coin.amount }
    end

    it do
      expect { subject }.to change(holder_coin, :quantity).by(-1)
    end
  end

  describe '#look_for_change' do
    subject { coin_holder.look_for_change(amount_to_change)&.map(&:as_json) }

    let(:amount_to_change) { 50 }
    let(:coin_holder) { build(:coin_holder, coins_json: coins_json) }
    let(:coins_json) do
      [
        quarter_dollar_coin,
        half_dollar_coin,
        one_dollar_coin,
        two_dollar_coin,
        three_dollar_coin,
        five_dollar_coin
      ].map do |attributes|
        attributes_for(:coin, attributes)
      end
    end
    let(:quarter_dollar_coin) { attributes_for(:quarter_dollar_coin, quantity: 2) }
    let(:half_dollar_coin) { attributes_for(:half_dollar_coin, quantity: 1) }
    let(:one_dollar_coin) { attributes_for(:one_dollar_coin, quantity: 1) }
    let(:two_dollar_coin) { attributes_for(:two_dollar_coin, quantity: 1) }
    let(:three_dollar_coin) { attributes_for(:three_dollar_coin, quantity: 1) }
    let(:five_dollar_coin) { attributes_for(:five_dollar_coin, quantity: 1) }

    context 'when enough Coins' do
      it 'to give change with maximum quantity of the coins with minimum amount' do
        is_expected.to eq([{ amount: 25, quantity: 2}])
      end
    end

    context 'when not enough Coins' do
      let(:quarter_dollar_coin) { Hash[amount: 25, quantity: 1] }
      let(:half_dollar_coin) { Hash[amount: 50, quantity: 0] }

      it { is_expected.to eq(nil) }
    end
  end

  describe '#to_s' do
    subject { coin_holder.to_s }

    it do
      is_expected.to eq("#{coin_holder.coins.map(&:to_s).join("\n")}")
    end
  end
end
