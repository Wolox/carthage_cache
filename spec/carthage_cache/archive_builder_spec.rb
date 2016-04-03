require "spec_helper"

describe CarthageCache::ArchiveBuilder do

  let(:cache_dir_name) { "carthage_cache" }
  let(:terminal) { MockTerminal.new(false) }
  let(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, terminal, TMP_PATH, MockSwiftVersionResolver.new) }
  let(:archiver) { CarthageCache::Archiver.new(MockCommandExecutor.new) }
  let(:repository) { double("repository") }
  subject(:archive_builder) { CarthageCache::ArchiveBuilder.new(terminal, repository, archiver, project) }

  describe "#build" do

    let(:archive_path) { File.join(project.tmpdir, project.archive_filename) }

    it "builds and uploads the archive" do
      expect(repository).to receive(:upload).with(project.archive_filename, archive_path)
      archive_builder.build
    end

  end

end
