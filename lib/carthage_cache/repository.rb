require "aws-sdk"
require 'fileutils'

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


  class LocalRepository
    attr_reader :project_directory

    def initialize(project_directory)
      @project_directory = project_directory
        
      unless File.exist?(@project_directory)
        FileUtils.mkdir_p(@project_directory)
      end
    end

    def archive_exist?(archive_filename)
      dir = File.join(project_directory, archive_filename)
      File.exist?(dir)
    end

    def download(archive_filename, destination_path)
      dirLocal = File.join(destination_path, archive_filename)
      dirDestination = File.join(@project_directory, archive_filename)
      FileUtils.cp(dirLocal, dirDestination)
    end

    def upload(archive_filename, archive_path)
      dirLocal = File.join(@project_directory, archive_filename)
      dirDestination = archive_path
      FileUtils.cp(dirDestination, dirLocal)
    end
  end
    

end
