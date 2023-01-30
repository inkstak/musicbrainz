# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "musicbrainz"
require "vcr"
require "webmock/rspec"
require "rspec/collection_matchers"
require "active_support"

unless RUBY_ENGINE == "truffleruby"
  require "simplecov"
  SimpleCov.start
end

VCR.configure do |c|
  c.hook_into :webmock
  c.debug_logger
  c.configure_rspec_metadata!
  c.cassette_library_dir                    = File.expand_path("fixtures", __dir__)
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options                = {
    record:            :none,
    match_requests_on: %i[method uri]
  }
end

CACHE_STORE = ActiveSupport::Cache.lookup_store(:file_store, "./tmp/cache")

MUSICBRAINZ_CONFIG = lambda { |config|
  config.app_name    = "MusicBrainz Test"
  config.app_version = MusicBrainz::VERSION
  config.contact     = "inkstak@users.noreply.github.com"
}

RSpec.configure do |config|
  # config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    MusicBrainz.configure(&MUSICBRAINZ_CONFIG)
  end
end
