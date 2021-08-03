# frozen_string_literal: true

RSpec.describe RubyVendingMachine::CoinHopper do
  subject(:coin_hopper) { build(:coin_hopper) }

  let(:coin) { build(:coin) }
  let(:hopper_coin) do
    coin_hopper.coins.find do |hopper_coin|
      hopper_coin.amount == coin.amount
    end
  end

  it { is_expected.to have_attributes(coins: coin_hopper.coins) }

  describe '#insert_coin' do
    subject { coin_hopper.insert_coin(coin) }

    it do
      expect { subject }.to change{ coin_hopper.inserted_cents_amount }
        .from(0).to(coin.amount)
    end
  end

  describe '#inserted_coins' do
    subject { coin_hopper.inserted_coins.map(&:as_json) }

    before { coin_hopper.insert_coin(coin) }

    it { is_expected.to eq([coin.as_json]) }
  end

  describe '#release_coins' do
    subject { coin_hopper.release_coins.map(&:as_json) }

    before { coin_hopper.insert_coin(coin) }

    it { is_expected.to eq([coin.as_json]) }
  end

  describe '#release_coins' do
    subject { coin_hopper.release_coins.map(&:as_json) }

    before { coin_hopper.insert_coin(coin) }

    it { is_expected.to eq([coin.as_json]) }
    it 'is expected to change inserted coins quantity to 0' do
      expect { subject }.to change {
        coin_hopper.inserted_coins.all? { |coin| coin.quantity == 0 }
      }.from(false).to(true)
    end
  end

  describe '#inserted_cents_amount' do
    subject { coin_hopper.inserted_cents_amount }

    before { coin_hopper.insert_coin(coin) }

    it { is_expected.to eq(coin.amount) }
  end

  describe '#as_json' do
    subject { coin_hopper.as_json }

    before { coin_hopper.insert_coin(coin) }

    it { is_expected.to eq(Hash[coins: coin_hopper.coins.map(&:as_json)]) }
  end
end
