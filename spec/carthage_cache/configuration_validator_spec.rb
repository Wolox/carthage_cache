require "spec_helper"

describe CarthageCache::ConfigurationValidator do

  let(:config) do
    config = CarthageCache::Configuration.new
    config.bucket_name = "carthage-cache"
    config.aws_region = "us-west-2"
    config.aws_access_key_id = "AAAAAAAAAAAAAAAAA"
    config.aws_secret_access_key = "BBBBBBBBBBBBBBBBBBBBBBBBBB"
    config
  end
  subject(:validator) { CarthageCache::ConfigurationValidator.new(config) }

  describe "#valid?" do

    context "when required configuration keys are missing" do


      context "when the bucket name is missing" do

        before(:each) { config.bucket_name = nil }

        it "returns false" do
          expect(validator.valid?).to be_falsy
        end

      end

      context "when the AWS region is missing" do

        before(:each) { config.aws_region = nil }

        it "returns false" do
          expect(validator.valid?).to be_falsy
        end

      end

      context "when the AWS access key ID is missing" do

        before(:each) { config.aws_access_key_id = nil }

        it "returns false" do
          expect(validator.valid?).to be_falsy
        end

      end

      context "when the AWS secret access key is missing" do

        before(:each) { config.aws_secret_access_key = nil }

        it "returns false" do
          expect(validator.valid?).to be_falsy
        end

      end

    end

    context "when the configuration object is valid" do

      it "returns true" do
        expect(validator.valid?).to be_truthy
      end

    end

  end

end
