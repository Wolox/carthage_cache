require "spec_helper"

describe CarthageCache::Archiver do

  let(:executor) { double("executor") }
  let(:build_directory) { File.join(FIXTURE_PATH, "Carthage/Build") }
  let(:archive_path) { File.join(TMP_PATH, "archive.zip") }
  subject(:archiver) { CarthageCache::Archiver.new(executor) }

  before(:each) do
    FileUtils.mkdir_p(build_directory)
    `unzip -o #{archive_path} -d #{build_directory} > /dev/null`
  end

  after(:each) do
    FileUtils.rm_r(build_directory)
  end

  describe "#archive" do

    it "creates a zip file with the content of the project's 'Carthage/Build' directory" do
      expected_command = "cd #{build_directory} && zip -r -X -y #{archive_path} CarthageCache.lock iOS Mac tvOS watchOS > /dev/null"
      expect(executor).to receive(:execute).with(expected_command)
      archiver.archive(build_directory, archive_path)
    end

    context "when a filter block is passed" do

      it "filters platforms that don't match the filter" do
        expected_command = "cd #{build_directory} && zip -r -X -y #{archive_path} CarthageCache.lock iOS > /dev/null"
        expect(executor).to receive(:execute).with(expected_command)
        archiver.archive(build_directory, archive_path) do |x|
          x == CarthageCache::CarthageCacheLock::LOCK_FILE_NAME || x == "iOS"
        end
      end

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
