require "yaml"

module CarthageCache

  class Configurator

    CONFIG_FILE_NAME = ".carthage_cache.yml"

    attr_reader :config_file_path
    attr_reader :base_config

    def initialize(project_path, base_config = {})
      @config_file_path = File.join(project_path, CONFIG_FILE_NAME)
      @base_config = merge_config(base_config)
    end

    def config
      @config ||= load_config
    end

    def save_config(config)
      raise "Invalid configuration" unless config.valid?
      File.open(config_file_path, 'w') { |f| f.write config.to_yaml }
    end

    private

      def config_file_exist?
        File.exist?(config_file_path)
      end

      def load_config
        if config_file_exist?
          config = Configuration.parse(File.read(config_file_path))
          config.merge(base_config)
        else
          base_config
        end
      end

      def remove_nil_keys(hash)
        hash.inject({}) do |new_hash, (k,v)|
          unless v.nil? || (v.respond_to?(:empty?) && v.empty?)
            if v.class == Hash
              cleaned_hashed = remove_nil_keys(v)
              new_hash[k] = cleaned_hashed unless cleaned_hashed.empty?
            else
              new_hash[k] = v
            end
          end
          new_hash
        end
      end

      def merge_config(config)
        new_config = Configuration.default.hash_object.merge(config)
        Configuration.new(remove_nil_keys(new_config))
      end

  end

end
