require "spec_helper"

describe CarthageCache::ArchiveInstaller do

  let(:cache_dir_name) { "carthage_cache" }
  let(:terminal) { MockTerminal.new(false) }
  let(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, terminal, TMP_PATH) }
  let(:archiver) { CarthageCache::Archiver.new(MockCommandExecutor.new) }
  let(:repository) { double("repository") }
  subject(:archive_installer) { CarthageCache::ArchiveInstaller.new(terminal, repository, archiver, project) }

  describe "#install" do

    let(:archive_path) { File.join(project.tmpdir, project.archive_filename) }

    it "downloads and installs the archive" do
      # download expectation
      expect(repository).to receive(:download).with(project.archive_filename, archive_path)
      # install expectation
      expect(archiver).to receive(:unarchive).with(archive_path, project.carthage_build_directory)

      archive_installer.install
    end

  end

end
