require "spec_helper"

describe CarthageCache::BuildCollector do

  let(:terminal) { MockTerminal.new(true) }
  let(:carthage_directory) { File.join(FIXTURE_PATH, "Carthage") }
  let(:build_directory) { File.join(carthage_directory, "Build") }
  let(:required_frameworks) { ["Neon", "Result"] }
  let(:all_frameworks) { required_frameworks + ["FakeLibrary"] }
  let(:archive_path) { File.join(TMP_PATH, "archive.zip") }
  subject(:collector) { CarthageCache::BuildCollector.new(terminal, build_directory, required_frameworks) }

  def framework_exist?(framework_name)
    %w(Mac  iOS  tvOS	watchOS).all? do |platform|
      framework = File.join(build_directory, platform, "#{framework_name}.framework")
      File.exist?(framework)
    end
  end

  RSpec::Matchers.define :exist_for_all_platforms do
    match do |frameworks|
      frameworks.all? { |framework_name| framework_exist?(framework_name) }
    end

    match_when_negated do |*frameworks|
      frameworks.none? { |framework_name| framework_exist?(framework_name) }
    end
  end

  before(:each) do
    FileUtils.mkdir_p(build_directory)
    `unzip -o #{archive_path} -d #{build_directory} > /dev/null`
  end

  after(:each) do
    FileUtils.rm_r(carthage_directory)
  end

  describe "#delete_unused_frameworks" do

    it "deletes unused frameworks from all targets" do
      expect(all_frameworks).to exist_for_all_platforms

      collector.delete_unused_frameworks

      expect(["FakeLibrary"]).not_to exist_for_all_platforms
      expect(required_frameworks).to exist_for_all_platforms
    end

    context "when a white list is provided" do

      let(:white_list) { { "FakeLibrary" => "Neon" } }

      it "does not deletes unsued frameworks from the white list" do
        expect(all_frameworks).to exist_for_all_platforms

        collector.delete_unused_frameworks(white_list)

        expect(required_frameworks).to exist_for_all_platforms
      end

    end

  end

end
