module CarthageCache

  class Terminal

    attr_reader :verbose

    def initialize(verbose = false)
      @verbose = verbose
    end

    def puts(message)
      Kernel.puts(message)
    end

    def vputs(message)
      puts(message) if verbose
    end

  end

end
