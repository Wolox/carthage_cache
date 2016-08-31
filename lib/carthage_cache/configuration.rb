require "yaml"

module CarthageCache

  class Configuration

    def self.supported_keys
      @supported_keys ||= []
    end

    def self.config_key(name)
      supported_keys << name
    end

    def self.valid?(config)
      ConfigurationValidator.new(config).valid?
    end

    def self.read_only?(config)
      ConfigurationValidator.new(config).read_only?
    end
      
    def self.local_only?(config)
      ConfigurationValidator.new(config).local_only?
    end
      
    def self.parse(str)
      new(YAML.load(str))
    end

    def self.default
      @default ||= Configuration.new({
        aws_s3_client_options: {
          region: ENV['AWS_REGION'],
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          profile: ENV['AWS_PROFILE']
        },
        tmpdir: Dir.tmpdir
      })
    end

    config_key :bucket_name
    config_key :aws_region
    config_key :aws_access_key_id
    config_key :aws_secret_access_key
    config_key :aws_profile
    config_key :tmpdir
    config_key :local_mode

    attr_reader :hash_object

    def initialize(hash_object = {})
      @hash_object = hash_object
    end

    def to_yaml
      hash_object.to_yaml
    end

    def valid?
      self.class.valid?(self)
    end

    def read_only?
      self.class.read_only?(self)
    end
      
    def local_only?
      self.class.local_only?(self)
    end
      
    def merge(c)
      if c.is_a?(Hash)
        @hash_object = hash_object.merge(c)
      else
        @hash_object = hash_object.merge(c.hash_object)
      end
      self
    end

    def method_missing(method_sym, *arguments, &block)
      method_name = method_sym.to_s
      key = method_name.chomp("=")
      return super if !self.class.supported_keys.include?(key.to_sym)
      config, key = extract_config_and_key(key)

      if method_name.end_with?("=")
        config[key] = arguments.first
      else
        config[key]
      end
    end

    def respond_to?(method_sym, include_private = false)
      if self.class.supported_keys.include?(method_sym)
        true
      else
        super
      end
    end

    private

      def extract_config_and_key(method_name)
        if method_name =~ /^aws_(.*)$/
          [hash_object[:aws_s3_client_options] ||= {}, $1.to_sym]
        else
          [hash_object, method_name.to_sym]
        end
      end

  end

end
