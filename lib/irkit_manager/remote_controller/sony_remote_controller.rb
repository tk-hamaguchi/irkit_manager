module IrkitManager
  class SonyRemoteController < RemoteController

    VENDOR_TYPE = :sony

    T   = 600
    FSC = 40

    LEADER = [4,1]
    SPAN   = 45_000

    @@command = nil

    def t
      T
    end

    def fsc
      FSC
    end

    def address_bits
      format = case SIRC_VERSION
               when 12
                 '%05b'
               when 15
                 '%08b'
               when 20
                 #'%05b'
                 '%013b'
               else
                 fail NotImplementedError
               end
      (format % ADDRESS).split(//).map(&:to_i)
    end

    def press(command)
      fail NotImplementedError unless @@command.has_key? command
      command  = ('%07b' % @@command[command]).split(//).map{ |v| v.to_i + 1 }
      address  = address_bits.map{ |v| v + 1 }
      sequence = LEADER + (command + address).each_with_object([]) { |v,ary| ary << [(v * t), t] }.flatten
      sequence.pop
      margin = (SPAN * 2 - sequence.inject(0) { |sum,v| sum += v ; sum })
      req = REPEAT.times.inject([]) do |ary,i|
              ary << margin unless ary.empty?
              ary << sequence
              ary
            end.flatten
      req_data = Hashie::Mash.new({
                   data: req,
                   format: 'raw',
                   freq: fsc
                 })
      irkit.post_messages req_data
    end
  end
end
