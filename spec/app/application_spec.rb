# frozen_string_literal: true

RSpec.describe RubyVendingMachine::Application do
  subject(:vending_machine) { build(:application) }

  let(:crisps_product) { vending_machine.stock.first }

  describe '#select_product_to_buy' do
    subject { vending_machine.select_product_to_buy(crisps_product) }

    it 'saves Product as selected' do
      expect { subject }.to change { vending_machine.selected_product }
        .from(nil).to(crisps_product)
    end
  end

  describe '#insert_coin' do
    subject { vending_machine.insert_coin(coin) }

    before { vending_machine.select_product_to_buy(crisps_product) }

    let(:coin) { build(:two_dollar_coin) }


    context 'when not enough Money to pay' do
      let(:coin) { build(:quarter_dollar_coin) }

      it do
        is_expected.to eq(
          Hash[message: :large_mount_needed,
               data: { amount: coin.amount - crisps_product.price_cents }]
        )
      end
    end
  end
end
