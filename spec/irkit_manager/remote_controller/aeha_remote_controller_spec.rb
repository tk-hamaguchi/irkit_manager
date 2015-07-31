require 'spec_helper'

RSpec.describe IrkitManager::AehaRemoteController do
  context 'with dummy class' do
    let(:klass) {
      Class.new(described_class) do
        CUSTOMER_CODE = 0b0011010001001011
        @@command = {
          tst: [0xd, 0x8c, 0x16]
        }
        def initialize(irkit)
          super(irkit, CUSTOMER_CODE)
        end
        def press(command)
          super(@@command[command])
        end
      end
    }
    let(:irkit) {
      double(IRKit, post_messages: true)
    }
    subject { klass.new(irkit) }

    context '#press' do
      context 'with args,' do
        context 'for example' do
          context ':tst' do
            subject { super().press(:tst) }
            it { expect{subject}.to_not raise_error }
            it {
              expect(irkit).to receive(:post_messages).with({"data"=>[6800,3400,850,850,850,850,850,2550,850,2550,850,850,850,2550,850,850,850,850,850,850,850,2550,850,850,850,850,850,2550,850,850,850,2550,850,2550,850,2550,850,850,850,850,850,850,850,2550,850,2550,850,850,850,2550,850,2550,850,850,850,850,850,850,850,2550,850,2550,850,850,850,850,850,850,850,850,850,850,850,2550,850,850,850,2550,850,2550,850,850,850],"format"=>"raw","freq"=>38})
              subject
            }
          end
        end
      end
    end
  end
end

