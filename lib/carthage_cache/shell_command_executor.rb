module CarthageCache

  class ShellCommandExecutor

    def execute(command)
      `#{command}`
    end

  end

end
