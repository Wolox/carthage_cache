require "spec_helper"

describe CarthageCache::ArchiveInstaller do

  let(:cache_dir_name) { "carthage_cache" }
  let(:terminal) { MockTerminal.new(false) }
  let(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, nil, terminal, TMP_PATH) }
  let(:archiver) { CarthageCache::Archiver.new(MockCommandExecutor.new) }
  let(:repository) { double("repository") }
  subject(:archive_installer) { CarthageCache::ArchiveInstaller.new(terminal, repository, archiver, project) }

  describe "#install" do

    context "when there is no copy of the archive in the local cache" do

      let(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, nil, terminal, TMP_PATH) }
      let(:archive_path) { File.join(project.tmpdir, project.archive_path) }

      it "downloads and installs the archive" do
        # download expectation
        expect(repository).to receive(:download).with(project.archive_filename, archive_path)
        # install expectation
        expect(archiver).to receive(:unarchive).with(archive_path, project.carthage_build_directory)

        archive_installer.install
      end

    end

    context "when there is a copy of the archive in the local cache" do

      let(:project) { CarthageCache::Project.new(FIXTURE_WITH_CACHE_PATH, cache_dir_name, nil, terminal, TMP_PATH) }
      let(:archive_path) { File.join(project.tmpdir, project.archive_path) }

      before do
        FileUtils.cp(File.join(FIXTURE_ARCHIVE_PATH, "archive.zip"), archive_path)
      end

      after do
        FileUtils.rm(archive_path)
      end

      it "installs the archive without downloading it" do
        # without downloading expectation
        expect(repository).to_not receive(:download)
        # install expectation
        expect(archiver).to receive(:unarchive).with(archive_path, project.carthage_build_directory)

        archive_installer.install
      end
    end

  end

end
