require "spec_helper"

describe CarthageCache::Archiver do

  let(:executor) { double("executor") }
  let(:build_directory) { File.join(FIXTURE_PATH, "Carthage/Build") }
  let(:archive_path) { File.join(TMP_PATH, "archive.zip") }
  subject(:archiver) { CarthageCache::Archiver.new(executor) }

  describe "#archive" do

    it "creates a zip file with the content of the project's 'Carthage/Build' directory" do
      expected_command = "cd #{build_directory} && zip -r -X #{archive_path} iOS Mac tvOS watchOS > /dev/null"
      expect(executor).to receive(:execute).with(expected_command)
      archiver.archive(build_directory, archive_path)
    end

  end

  describe "#unarchive" do

    it "unzips the archive file into the project's 'Carthage/Build' directory" do
      expected_command = "unzip -o #{archive_path} -d #{build_directory} > /dev/null"
      expect(executor).to receive(:execute).with(expected_command)
      archiver.unarchive(archive_path, build_directory)
    end

  end

end
