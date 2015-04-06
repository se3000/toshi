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

        blockchain = Blockchain.new
        processor = Toshi::Processor.new
        blockchain.load_from_json("simple_chain_1.json")
        blockchain.chain['main'].each{|height, block|
          processor.process_block(block, raise_errors=true)
        }
      end

      it { is_expected.to change { Toshi.db[:unconfirmed_addresses_outputs].count }.by(-1) }
      it { is_expected.to change { UnconfirmedAddress.count }.by(-1) }
      it { is_expected.to change { UnconfirmedOutput.count }.by(-1) }
      it { is_expected.to change { UnconfirmedInput.count }.by(-1) }
      it { is_expected.to change { UnconfirmedTransaction.count }.by(-1) }
      it { is_expected.to change { UnconfirmedRawTransaction.count }.by(-1) }

      it { is_expected.not_to change { Output.count } }
      it { is_expected.not_to change { Input.count } }
      it { is_expected.not_to change { Address.count } }
      it { is_expected.not_to change { Transaction.count } }
      it { is_expected.not_to change { RawTransaction.count } }
      it { is_expected.not_to change { Block.count } }
      it { is_expected.not_to change { RawBlock.count } }
    end
  end
end
