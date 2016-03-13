require "spec_helper"

describe CarthageCache::CartfileResolvedFile do

  let(:cartfile_resolved_path) { File.join(FIXTURE_PATH, "Cartfile.resolved") }
  subject(:cartfile_resolved) { CarthageCache::CartfileResolvedFile.new(cartfile_resolved_path) }

  describe "#digest" do

    it "returns a digest of the Cartfile.resolved file content" do
      expect(cartfile_resolved.digest).to eq("a7389856777fbb43a5c5eecf4b30a1b0aabc4a3bfba91a3713c5c7f342b11941")
    end

  end

  describe "#content" do

    it "returns the Cartfile.resolved file contet" do
      expect(cartfile_resolved.content).to eq(File.read(cartfile_resolved_path))
    end

  end

end
