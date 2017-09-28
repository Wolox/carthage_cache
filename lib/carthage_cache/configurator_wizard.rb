module CarthageCache

  class ConfiguratorWizard

    def initialize(ask_proc, password_proc)
      @ask_proc = ask_proc
      @password_proc = password_proc
    end

    def start
      config = Configuration.new
      config.bucket_name = ask("What is the Amazon S3 bucket name?", ENV["CARTHAGE_CACHE_DEFAULT_BUCKET_NAME"])
      config.path = ask("What path do you want to use? (optional)?", nil) 
      config.prune_on_publish = confirm("Do you want to prune unused framework when publishing?")
      config.aws_region = ask("What is the Amazon S3 region?")
      config.aws_access_key_id = password("What is the AWS access key?")
      config.aws_secret_access_key = password(" What is the AWS secret access key?")
      config.aws_session_token = ask("What is the AWS session token (optional)?", nil, "*") 
      config
    end

    private

      def ask(message, default_value = nil, mask = nil)
        message = "#{message} [#{default_value}]" if default_value
        if mask
          answer = @ask_proc.call(message) { |q| q.echo = mask } 
        else
          answer = @ask_proc.call(message)  
        end
        
        if answer.empty?
          default_value
        else
          answer
        end
      end

      def confirm(message)
        ask("#{message} [N/y]", 'N').downcase == 'y'
      end

      def password(message)
         @password_proc.call(message)
      end

  end

end
