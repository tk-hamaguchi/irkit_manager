module IrkitManager
  class RemoteController
    attr_reader :irkit

    def initialize(irkit)
      @irkit = irkit
    end

    def vendor_type
      fail NotImplementedError
    end

    def t
      fail NotImplementedError
    end

    def fsc
      fail NotImplementedError
    end

    def press(command)
      fail NotImplementedError
    end

    def irkit
      @irkit
    end
  end
end
