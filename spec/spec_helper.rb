require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'carthage_cache'
require_relative './mocks/mock_terminal'
require_relative './mocks/mock_command_executor'
require_relative './mocks/mock_swift_version_resolver'

FIXTURE_PATH = File.expand_path('../fixtures/project', __FILE__)
FIXTURE_WITH_CACHE_PATH = File.expand_path('../fixtures/project_with_cache', __FILE__)
TMP_PATH = File.expand_path('../fixtures/tmp', __FILE__)
FIXTURE_ARCHIVE_PATH = File.expand_path('../fixtures', __FILE__)
