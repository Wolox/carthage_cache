require "spec_helper"
require "fileutils"

describe CarthageCache::Application do

  let(:repository) { double("repository") }
  let(:options) { { repository: double("repository_class", new: repository), terminal: MockTerminal, executor: MockCommandExecutor } }
  let(:archive_filename) { "40bd802e1cef444564ccceecf8929fcaa38d5fb25c02ecc01b6fcdbea24ed2d7.zip" }
  let(:tmpdir) { File.join(TMP_PATH, "carthage_cache") }
  let(:archive_path) { File.join(tmpdir, archive_filename) }
  subject(:application) { CarthageCache::Application.new(FIXTURE_PATH, false, { tmpdir: TMP_PATH }, options) }

  describe "#archive_exist?" do

    context "when there is no archive for the given Cartfile.resolved file" do

      it "returns false" do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
        expect(application.archive_exist?).to be_falsy
      end

    end

    context "when there is an archive for the given Cartfile.resolved file" do

      it "returns true" do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        expect(application.archive_exist?).to be_truthy
      end

    end

  end

  describe "#install_archive" do

    before(:each) do
      FileUtils.cp(File.join(tmpdir, "archive.zip"), archive_path)
    end

    after(:each) do
      FileUtils.rm(archive_path)
    end

    context "when there is no archive for the given Cartfile.resolved file" do

      before(:each) do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
      end

      it "returns false" do
        expect(application.install_archive).to be_falsy
      end

    end

    context "when there is an archive for the given Cartfile.resolved file" do

      let(:carthage_build_directory) { File.join(FIXTURE_PATH, "Carthage/Build") }

      before(:each) do
        expect(repository).to receive(:download).with(archive_filename, archive_path)
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        FileUtils.rm_r(carthage_build_directory) if File.exist?(carthage_build_directory)
      end

      it "returns true" do
        expect(application.install_archive).to be_truthy
      end

      it "downloads and install the archive" do
        application.install_archive
        expect(File.exist?(carthage_build_directory)).to be_truthy
      end

    end

  end

  describe "#create_archive" do

    after(:each) do
      FileUtils.rm(archive_path) if File.exist?(archive_path)
    end

    context "when a the force parameter is set to true" do

      context "when an archive already exists" do

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive(true)
        end

      end

      context "when an archive does not exists" do

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive(true)
        end

      end

    end

    context "when a the force parameter is set to false" do

      context "when an archive already exists" do

        before(:each) do
          expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        end

        it("returns false") do
          expect(application.create_archive).to be_falsy
        end

        it("does not upload the archive") do
          expect(repository).not_to receive(:upload)
          application.create_archive
        end

      end

      context "when an archive does not exists" do

        before(:each) do
          expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
        end

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive
        end

      end

    end

  end

end
