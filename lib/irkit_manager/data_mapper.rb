module IrkitManager
  module DataMapper

    VOLUME_UP   = :volume_up
    VOLUME_DOWN = :volume_down
    POWER       = :power
    MUTING      = :muting

    DATA_WITH_VENDOR_ID_FUNC = {
      sony: {
        '0x000c' => {
          '0x54' => POWER,
          '0x24' => VOLUME_UP,
          '0x64' => VOLUME_DOWN,
          '0x14' => MUTING,
          '0x5f' => :input_dvd
        },
        '0x0010' => {
          '0x52' => POWER,
        }
      }
    }

    def convert_to_symbol(type:, func_code:, id_code:)
      hex_id_code   = '0x%04x' % id_code
      hex_func_code = '0x%02x' % func_code
      fail "Unkown type #{type}." unless DATA_WITH_VENDOR_ID_FUNC.has_key? type
      fail "Unkown identification code #{hex_id_code}." unless DATA_WITH_VENDOR_ID_FUNC[type].has_key? hex_id_code
      fail "Unkown function code #{hex_func_code}." unless DATA_WITH_VENDOR_ID_FUNC[type][hex_id_code].has_key? hex_func_code
      DATA_WITH_VENDOR_ID_FUNC[type][hex_id_code][hex_func_code]
    end


    def convert_to_code(type:, id_code:, func_symbol:)
      hex_id_code   = '0x%04x' % id_code
      fail "Unkown type #{type}." unless DATA_WITH_VENDOR_ID_FUNC.has_key? type
      fail "Unkown identification code #{hex_id_code}." unless DATA_WITH_VENDOR_ID_FUNC[type].has_key? hex_id_code
      fail "Unkown function symbol #{func_symbol}." unless DATA_WITH_VENDOR_ID_FUNC[type][hex_id_code].invert.has_key? func_symbol
      DATA_WITH_VENDOR_ID_FUNC[type][hex_id_code].invert[func_symbol]
    end

    module_function :convert_to_symbol, :convert_to_code

  end
end
