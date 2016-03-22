require "spec_helper"

describe CarthageCache::CartfileResolvedFile do

  let(:cartfile_resolved_path) { File.join(FIXTURE_PATH, "Cartfile.resolved") }
  subject(:cartfile_resolved) { CarthageCache::CartfileResolvedFile.new(cartfile_resolved_path, MockCommandExecutor.new) }

  describe "#digest" do

    it "returns a digest of the Cartfile.resolved file content" do
      expect(cartfile_resolved.digest).to eq("40bd802e1cef444564ccceecf8929fcaa38d5fb25c02ecc01b6fcdbea24ed2d7")
    end

  end

  describe "#content" do

    it "returns the Cartfile.resolved file contet" do
      expect(cartfile_resolved.content).to eq(File.read(cartfile_resolved_path))
    end

  end

end
