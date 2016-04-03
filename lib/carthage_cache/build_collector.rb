require 'fileutils'

module CarthageCache

  class BuildCollector

    attr_reader :terminal
    attr_reader :build_directory
    attr_reader :required_frameworks

    def initialize(terminal, build_directory, required_frameworks)
      @terminal = terminal
      @build_directory = build_directory
      @required_frameworks = Set.new(required_frameworks)
    end

    def delete_unused_frameworks(white_list = {})
      terminal.vputs "Deleting unused frameworks from '#{build_directory}' ..."
      list_built_frameworks.each do |framework_path|
        if delete_framework?(framework_path, white_list)
          terminal.vputs "Deleting '#{framework_path}' because is not longer needed."
          FileUtils.rm_r(framework_path)
          FileUtils.rm_r("#{framework_path}.dSYM")
          # TODO delete corresponding .bcsymbolmap file
        end
      end
    end

    private

      def delete_framework?(framework_path, white_list)
        framework = framework_name(framework_path)
        if required_frameworks.include?(white_list[framework])
          false
        else
          ! required_frameworks.include?(framework)
        end
      end

      def list_built_frameworks
        Dir[File.join(build_directory, "/**/*.framework")]
      end

      def framework_name(framework_path)
        Pathname.new(framework_path).basename(".framework").to_s
      end

  end

end
