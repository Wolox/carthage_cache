require "aws-sdk"

module CarthageCache

  class Repository

    DEFAULT_BUCKET_NAME = "carthage-cache"

    attr_reader :client
    attr_reader :bucket_name

    def initialize(bucket_name = DEFAULT_BUCKET_NAME, client_options = {})
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

end
