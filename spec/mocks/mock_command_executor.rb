class MockCommandExecutor

  def execute(command)
    if command == 'xcrun swift -version'
      "Apple Swift version 3.0 (swiftlang-703.0.18.1 clang-703.0.29)\nTarget: x86_64-apple-macosx10.9"
    end
  end

end
