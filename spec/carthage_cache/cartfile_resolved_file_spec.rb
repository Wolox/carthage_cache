require "spec_helper"

describe CarthageCache::CartfileResolvedFile do

  let(:cartfile_resolved_path) { File.join(FIXTURE_PATH, "Cartfile.resolved") }
  let(:terminal) { MockTerminal.new(false) }
  let(:swift_version_resolver) { MockSwiftVersionResolver.new }
  subject(:cartfile_resolved) { CarthageCache::CartfileResolvedFile.new(cartfile_resolved_path, terminal, swift_version_resolver) }

  describe "#digest" do

    it "returns a digest of the Cartfile.resolved file content" do
      expect(cartfile_resolved.digest).to eq("076c322e6651c2c39a01790b4b525a79ec17f49e1b847275418ec512a4cb0396")
    end

  end

  describe "#content" do

    it "returns the Cartfile.resolved file contet" do
      expect(cartfile_resolved.content).to eq(File.read(cartfile_resolved_path))
    end

  end

  describe "#frameworks" do

    it "returns a list of framewokrs name" do
      expect(cartfile_resolved.frameworks).to eq(["Neon", "Result"])
    end

  end

end
