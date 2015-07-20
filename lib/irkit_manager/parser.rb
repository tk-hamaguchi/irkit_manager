module IrkitManager
  class Parser

    class << self
      def support?(data)
        (!type(data).nil?)
      end

      def type(data)
        each_parser do |klass|
          return klass if klass.support?(data)
        end
        nil
      end

      def parse(data)
        type(data).parse(data)
      end

      private

      def each_parser
        (self.constants - [:Base]).each do |klass|
          yield self.const_get(klass)
        end
      end
    end

    module Base
    end

    class Nec
      include Base

      class << self
        def support?(data)
          false
        end
      end
    end

    class Sony
      include Base

      class << self
        def support?(data)
          (4200..5400).include? data.first
        end

        def parse(data)
          to_sony_sequence(data).each_with_object([]) do |sequence, result|
            leader = sequence.shift(2)
            t = leader[1]
            case (leader[0].to_f / t).round
            when 4
              func_code,id_code = parse_sony_sequence(sequence, t)
              result << Data::Sony.new(
                func_code: func_code,
                id_code:   id_code
              )
            else
              fail "Unknown margin #{(leader[0].to_f / t).round}:1."
            end
          end
        end

        private

        def to_sony_sequence(data)
          chunk = []
          array = []
          sum = 0
          data.each { |v|
            sum += v
            if (sum > 45_000 * 2)
              sum = v
              chunk << array
              array = []
            end
            array << v
          }
          chunk << array
          chunk
        end

        def parse_sony_sequence(sequence, t)
          data_bits = sequence.each_with_index.select{ |x|
                        ( x[1] % 2 == 0 )
                      }.each_with_object([]){ |obj, ary|
                        ary << ((obj[0].to_f / t).round - 1)
                      }
          func_code = Integer("0b#{data_bits.shift(7).join('')}")
          id_code   = Integer("0b#{data_bits.join('')}")
          [func_code, id_code]
        end

      end
    end

    class Aeha
      include Base

      class << self
        def support?(data)
          (5250..8500).include? data.first
        end

        def parse(data)
          result = []
          frames = parse_to_frame(data.dup)
          frames.each do |frame|
            customer = [Integer("0b#{frame.shift(4).join}")]
            customer << Integer("0b#{frame.shift(4).join}")
            customer << Integer("0b#{frame.shift(4).join}")
            customer << Integer("0b#{frame.shift(4).join}")

            unless customer.inject(0) { |sum, val| sum ^ val } == Integer("0b#{frame.shift(4).join}")
              fail RuntimeError, 'Parse error!  customer parity error.'
            end
            customer_code = Integer(format('0x%01x%01x%01x%01x', *customer))
            data = [Integer("0b#{frame.shift(4).join}")]
            frame.each_slice(8).each do |ary|
              data << Integer('0b' + ary.join)
            end
            result << Data::Aeha.new(customer_code: customer_code, data: data)
          end
          result
        end

        private

        def parse_to_frame(data)
          data2 = data.dup
          data2.shift(2)
          result = []
          ary = []
          data2.map{ |v| (v.to_f / (425)).round }.map{ |v| v / 2 }.each_slice(2) { |chunk|
            if chunk == [8, 4]
            elsif chunk == [1, 1]
              ary << 0
            elsif chunk == [1, 3]
              ary << 1
            elsif chunk == [1]
              result << ary unless ary.empty?
              ary = []
            else
              if chunk.last > 5
                result << ary unless ary.empty?
                ary = []
                next
              end

              fail RuntimeError, "Parse error!  #{chunk}"
            end
          }
          result
        end
      end
    end
  end

  module Data
    class Sony
      attr_accessor :func_code, :id_code

      def initialize(func_code:, id_code:)
        @func_code = func_code
        @id_code = id_code
      end

      def ==(obj)
        ((func_code == obj.func_code) && (id_code == obj.id_code))
      end
    end

    class Aeha
      attr_accessor :customer_code, :data

      def initialize(customer_code:, data:)
        @customer_code = customer_code
        @data = data
      end

      def ==(obj)
        ((customer_code == obj.customer_code) && (data == obj.data))
      end

      def to_a
        data = @data.dup
        [
          (@customer_code >> 8),
          (0b0000000011111111 & @customer_code),
          (((
            (@customer_code & 0b1111000000000000 >> 12) ^
            (@customer_code & 0b0000111100000000 >> 8) ^
            (@customer_code & 0b0000000011110000 >> 4) ^
            (@customer_code & 0b0000000000001111)) << 4) | data.shift),
        ] + data
      end
    end
  end
end

