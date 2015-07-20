module IrkitManager
  class AehaRemoteController < RemoteController

    VENDOR_TYPE = :aeha

    T   = 425
    FSC = 38

    LEADER = [8,4]

    @@command = nil

    def initialize(irkit, customer_code)
      super(irkit)
      @customer_code = customer_code
    end

    def t
      T
    end

    def fsc
      FSC
    end

    def customer_code_bit
      @customer_code
    end

    def parity_bit
      ((customer_code_bit & 0b1111000000000000) >> 12) ^
        ((customer_code_bit & 0b0000111100000000) >> 8) ^
        ((customer_code_bit & 0b0000000011110000) >> 4) ^
        (customer_code_bit & 0b0000000000001111)
    end

    def press(commands)
      fail NotImplementedError unless commands
      req = convert_to_code(commands).map { |c| c * t * 2}
      req_data = Hashie::Mash.new({
                   data: req,
                   format: 'raw',
                   freq: fsc
                 })
      irkit.post_messages req_data
    end

    def convert_to_code(commands)
      sequence = LEADER + bit_to_code(customer_code_bit, 16) + bit_to_code(parity_bit, 4)
      commands.each_with_index do |cmd, i|
        if i == 0
          sequence += bit_to_code(cmd, 4)
        else
          sequence += bit_to_code(cmd, 8)
        end
      end
      sequence += [1]
      sequence
    end

    def bit_to_code(bit, length)
      format("%0#{length}b", bit).split(//).map { |b|
        b.to_i == 0 ? [1, 1] : [1, 3]
      }.flatten
    end
  end
end
