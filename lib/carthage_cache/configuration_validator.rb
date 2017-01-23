module CarthageCache

  class MissingConfigurationKey < Struct.new(:keyname, :solution)

    def self.missing_bucket_name
      solution =  "You need to specify the AWS S3 bucket to be used.\n" \
                  "You can either pass the '--bucket-name' option or "  \
                  " add ':bucket_name: YOUR_BUCKET_NAME' to "           \
                  ".carthage_cache.yml file.\nYou can also run "        \
                  "'carthage_cache config' to generate the config file."
      self.new(:bucket_name, solution)
    end

    def self.missing_aws_key(keyname, name)
      solution =  "You need to specify the AWS #{name} to be used.\n"     \
                  "You can either define a enviromental variable "        \
                  "AWS_REGION or add ':#{keyname}: YOUR_KEY_VALUE' "      \
                  "under the :aws_s3_client_options: key in the "         \
                  ".carthage_cache.yml file.\nYou can also run "          \
                  "'carthage_cache config' to generate the config file."
      self.new("aws_s3_client_options.#{keyname}", solution)
    end

    def self.missing_aws_region
      missing_aws_key("region", "region")
    end

    def self.missing_aws_access_key_id
      missing_aws_key("access_key_id", "access key ID")
    end

    def self.missing_aws_secret_access_key
      missing_aws_key("secret_access_key", "secret access key")
    end

  end

  class ValidationResult

    def self.valid
      self.new(nil)
    end

    def self.invalid(error)
      self.new(error)
    end

    attr_reader :error

    def initialize(error)
      @error = error
    end

    def valid?
      @error == nil
    end

  end

  class ConfigurationValidator

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def valid?
      validate.valid?
    end

    def read_only?
      (config.aws_access_key_id.nil? || config.aws_secret_access_key.nil?) && config.aws_profile.nil?
    end
      
    def local_only?
      has_local_mode?
    end
    
    def validate
      return ValidationResult.valid if has_local_mode?    
      return missing_bucket_name unless has_bucket_name?
      return missing_aws_region unless has_aws_region?

      return missing_aws_access_key_id if is_missing_aws_access_key_id?
      return missing_aws_secret_access_key if is_missing_aws_secret_access_key?

      ValidationResult.valid
    end

    private

      def is_missing_aws_access_key_id? 
        !has_aws_profile? && !has_aws_access_key_id? && has_aws_secret_access_key?
      end

      def is_missing_aws_secret_access_key?
        !has_aws_profile? && has_aws_access_key_id? && !has_aws_secret_access_key?
      end

      def has_local_mode?
         config.local_mode
      end
      
      def has_bucket_name?
        config.bucket_name
      end

      def has_aws_region?
        config.aws_region
      end

      def has_aws_access_key_id?
        config.aws_access_key_id
      end

      def has_aws_secret_access_key?
        config.aws_secret_access_key
      end

      def has_aws_profile?
        config.aws_profile
      end

      def missing_bucket_name
        ValidationResult.invalid(MissingConfigurationKey.missing_bucket_name)
      end

      def missing_aws_region
        ValidationResult.invalid(MissingConfigurationKey.missing_aws_region)
      end

      def missing_aws_access_key_id
        ValidationResult.invalid(MissingConfigurationKey.missing_aws_access_key_id)
      end

      def missing_aws_secret_access_key
        ValidationResult.invalid(MissingConfigurationKey.missing_aws_secret_access_key)
      end

  end

end
