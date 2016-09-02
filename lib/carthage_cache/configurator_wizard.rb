module CarthageCache

  class ConfiguratorWizard

    def initialize(ask_proc, password_proc, project_path)
      @ask_proc = ask_proc
      @password_proc = password_proc
      @project_path = project_path
    end

    def start
        confirm = @ask_proc.call("Would you like to use AWS [Y/N]") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
        unless confirm.downcase == 'y'
            start_local_mode
        else
            start_aws
        end
    end
    
    def start_aws
      config = Configuration.new
      config.bucket_name = ask("What is the Amazon S3 bucket name?", ENV["CARTHAGE_CACHE_DEFAULT_BUCKET_NAME"])
      config.aws_region = ask("What is the Amazon S3 region?")
      config.aws_access_key_id = password("What is the AWS access key?")
      config.aws_secret_access_key = password(" What is the AWS secret access key?")
      config
    end
      
    def start_local_mode
      config = Configuration.new
      config.local_mode = File.join(@project_path, "Carthage", "Cache")
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

      def password(message)
        @password_proc.call(message)
      end
      
      
  end

end
