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

    def error(message)
      STDERR.puts(message)
    end

  end

end
