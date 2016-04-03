require "spec_helper"

describe CarthageCache::Project do

  let(:cache_dir_name) { "carthage_cache" }
  let(:terminal) { MockTerminal.new(false) }
  subject(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, terminal, TMP_PATH, MockSwiftVersionResolver.new) }

  describe "#archive_key" do

    it "returns the digest of the Cartfile.resolved file" do
      expect(project.archive_key).to eq("076c322e6651c2c39a01790b4b525a79ec17f49e1b847275418ec512a4cb0396")
    end

  end

  describe "#archive_filename" do

    it "returns the name of the archive for the current Cartfile.resolved file" do
      expect(project.archive_filename).to eq("076c322e6651c2c39a01790b4b525a79ec17f49e1b847275418ec512a4cb0396.zip")
    end

  end

  describe "#carthage_build_directory" do

    it "returns the project's Carthage build directory" do
      expect(project.carthage_build_directory).to eq(File.join(FIXTURE_PATH, "Carthage/Build"))
    end

  end

  describe "#tmpdir" do

    it "returns the project's temporary directory" do
      expect(project.tmpdir).to eq(File.join(TMP_PATH, cache_dir_name))
    end

  end

  describe "#all_frameworks" do

    it "returns all the project's dependencies" do
      expect(project.all_frameworks).to eq(["Neon", "Result"])
    end

  end

end
