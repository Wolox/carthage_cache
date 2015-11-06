module CarthageCache

  class Archiver

    def archive(archive_path, destination_path)
      files = Dir.entries(archive_path).select { |x| !x.start_with?(".") }
      `cd #{archive_path} && zip -r -X #{File.expand_path(destination_path)} #{files.join(' ')} > /dev/null`
    end

    def unarchive(archive_path, destination_path)
      `unzip #{archive_path} -d #{destination_path} > /dev/null`
    end

  end
  
end
