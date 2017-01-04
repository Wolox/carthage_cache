module CarthageCache

  class ConfiguratorWizard

    def initialize(ask_proc, password_proc)
      @ask_proc = ask_proc
      @password_proc = password_proc
    end

    def start
      config = Configuration.new
      config.bucket_name = ask("What is the Amazon S3 bucket name?", ENV["CARTHAGE_CACHE_DEFAULT_BUCKET_NAME"])
      config.prune_on_publish = confirm("Do you want to prune unused framework when publishing?")
      config.aws_region = ask("What is the Amazon S3 region?")
      config.aws_access_key_id = password("What is the AWS access key?")
      config.aws_secret_access_key = password(" What is the AWS secret access key?")
      config
    end

    private

      def ask(message, default_value = nil)
        message = "#{message} [#{default_value}]" if default_value
        answer = @ask_proc.call(message)
        if answer.empty?
          default_value
        else
          answer
        end
      end

      def confirm(message)
        ask("#{message} [N/y]").downcase == 'y'
      end

      def password(message)
        @password_proc.call(message)
      end

  end

end
