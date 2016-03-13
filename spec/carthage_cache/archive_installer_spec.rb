require "spec_helper"

describe CarthageCache::ArchiveInstaller do

  let(:cache_dir_name) { "spec_carthage_cache" }
  let(:terminal) { MockTerminal.new }
  let(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, terminal) }
  let(:archiver) { CarthageCache::Archiver.new(MockCommandExecutor.new) }
  let(:repository) { double("repository") }
  subject(:archive_installer) { CarthageCache::ArchiveInstaller.new(terminal, repository, archiver, project) }

  describe "#install" do

    let(:archive_path) { File.join(project.tmpdir, project.archive_filename) }

    it "downloads and installs the archive" do
      expect(repository).to receive(:download).with(project.archive_filename, archive_path)
      archive_installer.install
    end

  end

end
