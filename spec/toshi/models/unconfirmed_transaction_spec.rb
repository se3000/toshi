require 'spec_helper'

module Toshi::Models
  describe UnconfirmedTransaction do
    describe '.remove_all' do
      subject { lambda { UnconfirmedTransaction.remove_all } }

      before do
        raw_tx = UnconfirmedRawTransaction.create(hsh: fake_hash)
        tx = UnconfirmedTransaction.create(hsh: raw_tx.hsh)
        address = UnconfirmedAddress.create(address: testnet_address)
        output = UnconfirmedOutput.create(hsh: fake_hash, amount: 1e8, script: 'script')
        UnconfirmedInput.create(hsh: fake_hash, index: 0, prev_out: output.hsh)

        outputs = [output]
        addresses = [[address.address]]
        UnconfirmedTransaction.upsert_output_addresses(tx.id, outputs, outputs.map(&:id), addresses)
      end

      it { is_expected.to change { Toshi.db[:unconfirmed_addresses_outputs].count }.by(-1) }
      it { is_expected.to change { UnconfirmedAddress.count }.by(-1) }
      it { is_expected.to change { UnconfirmedOutput.count }.by(-1) }
      it { is_expected.to change { UnconfirmedInput.count }.by(-1) }
      it { is_expected.to change { UnconfirmedTransaction.count }.by(-1) }
      it { is_expected.to change { UnconfirmedRawTransaction.count }.by(-1) }
    end
  end
end
