require 'spec_helper'

describe CarthageCache::Configuration do

  describe 'defaults' do
    it 'has ~/Library/Caches/carthage_cache as the default temp directory' do
      expect(CarthageCache::Configuration.default.tmpdir).to eq File.join(Dir.home, 'Library', 'Caches')
    end
  end

  describe '#merge' do
    it 'merges keys in a sub hash without overwriting the existing whole subhash' do
      expected_hash = { :tmpdir=>"bar", :aws_s3_client_options=>{ :access_key_id=>"foo", :region=>"us-west-2"}}
      config = CarthageCache::Configuration.new
      subhash = { :access_key_id=>"foo" }
      config.hash_object[:tmpdir]="bar"
      config.hash_object[:aws_s3_client_options]=subhash

      other_subhash = { :region=>"us-west-2" }
      other_hash = { :aws_s3_client_options=>other_subhash }
      config.merge(other_hash)
      expect(config.hash_object).to eq(expected_hash)
    end

    it 'merges keys from another configuration object into this one correctly' do
      expected_hash = { :foo=>"bar", :baz=>"bum"}
      other_config = CarthageCache::Configuration.new
      other_config.hash_object[:foo]="bar"
      main_config = CarthageCache::Configuration.new
      main_config.hash_object[:baz]="bum"
      main_config.merge(other_config)
      expect(main_config.hash_object).to eq(expected_hash)
    end
  end
end
