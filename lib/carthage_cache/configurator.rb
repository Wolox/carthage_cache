require "yaml"

module CarthageCache

  class Configurator

    CONFIG_FILE_NAME = ".carthage_cache.yml"

    attr_reader :config_file_path
    attr_reader :base_config

    def initialize(project_path, base_config = {})
      @config_file_path = File.join(project_path, CONFIG_FILE_NAME)
      @base_config = default_configuration.merge(base_config)
    end

    def config
      @config ||= load_config
    end

    def save_config(config)
      if valid?(config)
        File.open(config_file_path, 'w') { |f| f.write config.to_yaml }
      end
    end

    private

      def config_file_exist?
        File.exist?(config_file_path)
      end

      def load_config
        if config_file_exist?
          config = YAML.load(File.read(config_file_path))
          raise "Invalid config file" unless valid?(config)
          config.merge(base_config)
        else
          base_config
        end
      end

      def valid?(config)
        config.has_key?(:aws_s3_client_options)             &&
        config[:aws_s3_client_options][:region]             &&
        config[:aws_s3_client_options][:access_key_id]      &&
        config[:aws_s3_client_options][:secret_access_key]
      end

      def deep_symbolize_keys(object)
        return object.inject({}) { |memo,(k,v)| memo[k.to_sym] = deep_symbolize_keys(v); memo } if object.is_a? Hash
        return object.inject([]) { |memo,v    | memo          << deep_symbolize_keys(v); memo } if object.is_a? Array
        return object
      end

      def default_configuration
        config = {
          bucket_name: nil,
          aws_s3_client_options: {}
        }
        config[:aws_s3_client_options][:region] = ENV['AWS_REGION'] if ENV['AWS_REGION']
        config[:aws_s3_client_options][:access_key_id] = ENV['AWS_ACCESS_KEY_ID'] if ENV['AWS_ACCESS_KEY_ID']
        config[:aws_s3_client_options][:secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY'] if ENV['AWS_SECRET_ACCESS_KEY']
        config.delete_if { |k, v| k == :aws_s3_client_options && v.empty? }
      end

  end

end
