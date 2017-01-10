require "spec_helper"

describe CarthageCache::BuildCollector do

  let(:terminal) { MockTerminal.new(true) }
  let(:executor) { double("executor") }
  let(:carthage_directory) { File.join(FIXTURE_PATH, "Carthage") }
  let(:build_directory) { File.join(carthage_directory, "Build") }
  let(:required_frameworks) { ["Neon", "Result"] }
  let(:all_frameworks) { required_frameworks + ["FakeLibrary"] }
  let(:platforms) { %w(Mac  iOS  tvOS	watchOS) }
  let(:archive_path) { File.join(TMP_PATH, "archive.zip") }
  let(:framework_uuids) do
    {
      "FakeLibrary" => [
        ["EE46A5E2-44E9-30A8-B9B9-9B3FA746E9A5", "i386"],
        ["FBD6D218-C1CF-31D0-BD02-7A55C3081421", "x86_64"],
        ["B79F0D11-1649-3B68-B396-9AFDE29AEA24", "armv7"],
        ["A03E7540-00B3-33FF-B20C-BBEC81A1A78F", "arm64"]
      ],
      "Neon" => [
        ["1E46A5E2-44E9-30A8-B9B9-9B3FA746E9A5", "i386"],
        ["1BD6D218-C1CF-31D0-BD02-7A55C3081421", "x86_64"],
        ["179F0D11-1649-3B68-B396-9AFDE29AEA24", "armv7"],
        ["103E7540-00B3-33FF-B20C-BBEC81A1A78F", "arm64"]
      ],
      "Result" => [
        ["2E46A5E2-44E9-30A8-B9B9-9B3FA746E9A5", "i386"],
        ["2BD6D218-C1CF-31D0-BD02-7A55C3081421", "x86_64"],
        ["279F0D11-1649-3B68-B396-9AFDE29AEA24", "armv7"],
        ["203E7540-00B3-33FF-B20C-BBEC81A1A78F", "arm64"]
      ]
    }
  end
  subject(:collector) { CarthageCache::BuildCollector.new(terminal, build_directory, required_frameworks, executor) }

  def symbol_map_path(platform, uuid)
    File.join(build_directory, platform, "#{uuid}.bcsymbolmap")
  end

  def symbol_maps_exist?(framework_name)
    uuids = framework_uuids[framework_name]
    return false unless uuids

    platforms.map { |platform| uuids.map { |uuid, arch| symbol_map_path(platform, uuid) } }
      .flatten
      .reduce(true) { |result, file| result && File.exist?(file) }
  end

  def dsym_path_for(framework_name, platform)
    File.join(build_directory, platform, "#{framework_name}.framework.dSYM")
  end

  def framework_exist?(framework_name)
    platforms.all? do |platform|
      framework = File.join(build_directory, platform, "#{framework_name}.framework")
      dSYM = dsym_path_for(framework_name, platform)
      File.exist?(framework) and File.exist?(dSYM) and symbol_maps_exist?(framework_name)
    end
  end

  def framework_not_exist?(framework_name)
    platforms.all? do |platform|
      framework = File.join(build_directory, platform, "#{framework_name}.framework")
      dSYM = dsym_path_for(framework_name, platform)
      !File.exist?(framework) and !File.exist?(dSYM) and !symbol_maps_exist?(framework_name)
    end
  end

  def framework_dsym_paths(framework)
    platforms.map { |platform| dsym_path_for(framework, platform) }
  end

  def mock_dwarfdump_command_for(frameworks)
    frameworks.each do |framework|
      framework_dsym_paths(framework).each do |dsym_path|
        expected_command = "/usr/bin/xcrun dwarfdump --uuid #{dsym_path}"
        mocked_output = framework_uuids[framework].map do |uuid, arch|
          "UUID: #{uuid} (#{arch}) #{dsym_path}/Contents/Resources/DWARF/#{framework}"
        end.join("\n")
        allow(executor).to receive(:execute).with(expected_command).and_return(mocked_output)
      end
    end
  end

  RSpec::Matchers.define :exist_for_all_platforms do
    match do |frameworks|
      frameworks.all? { |framework_name| framework_exist?(framework_name) }
    end

    match_when_negated do |frameworks|
      frameworks.all? { |framework_name| framework_not_exist?(framework_name) }
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
      mock_dwarfdump_command_for all_frameworks
      expect(all_frameworks).to exist_for_all_platforms

      collector.delete_unused_frameworks

      expect(["FakeLibrary"]).not_to exist_for_all_platforms
      expect(required_frameworks).to exist_for_all_platforms
    end

    context "when a white list is provided" do

      let(:white_list) { { "FakeLibrary" => "Neon" } }

      it "does not deletes unsued frameworks from the white list" do
        mock_dwarfdump_command_for all_frameworks
        expect(all_frameworks).to exist_for_all_platforms

        collector.delete_unused_frameworks(white_list)

        expect(required_frameworks).to exist_for_all_platforms
      end

    end

  end

end
