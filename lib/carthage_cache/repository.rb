require "aws-sdk"

module CarthageCache

  class AWSRepository

    attr_reader :client
    attr_reader :bucket_name

    def initialize(bucket_name, client_options = {})
      @client = ::Aws::S3::Client.new(client_options)
      @bucket_name = bucket_name
    end

    def archive_exist?(archive_filename)
      ::Aws::S3::Object.new(bucket_name, archive_filename, client: client).exists?
    end

    def download(archive_filename, destination_path)
      resp = client.get_object(
        response_target: destination_path,
        bucket: bucket_name,
        key: archive_filename)
    end

    def upload(archive_filename, archive_path)
      File.open(archive_path, 'rb') do |file|
        client.put_object(bucket: bucket_name, key: archive_filename, body: file)
      end
    end

  end

  class HTTPRepository

    attr_reader :base_url

    def initialize(bucket_name, client_options = {})
      region = client_options[:region]
      bucket_name = bucket_name
      @base_url = "https://s3-#{region}.amazonaws.com/#{bucket_name}"
    end

    def archive_exist?(archive_filename)
      system "wget", "--method=HEAD", "#{base_url}/#{archive_filename}", "-q"
    end

    def download(archive_filename, destination_path)
      system "wget", "--output-document=#{destination_path}", "#{base_url}/#{archive_filename}", "-q"
    end

    def upload(archive_filename, archive_path)
      raise "carthage_cache is working in read-only mode. Please configure AWS credentials first"
    end

  end

end
