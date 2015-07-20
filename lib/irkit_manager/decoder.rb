module IrkitManager
  module Decoder
    def execute!(data)
      fail RuntimeError, 'Unsupported format!' unless Parser.support?(data)
      Parser.parse(data)
    end

    module_function :execute!
  end
end
