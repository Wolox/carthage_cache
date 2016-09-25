require 'spec_helper'

describe CarthageCache::Configuration do

  describe 'defaults' do
    it 'has ~/Library/Caches/carthage_cache as the default temp directory' do
      expect(CarthageCache::Configuration.default.tmpdir).to eq File.join(Dir.home, 'Library', 'Caches')
    end
  end
end
