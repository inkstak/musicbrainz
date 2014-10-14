require 'rubygems'
require 'bundler/setup'
require 'musicbrainz'
require 'vcr'
require 'webmock/rspec'
require 'rspec/collection_matchers'
require 'awesome_print'
require 'active_support'

# https://github.com/rails/rails/pull/14667
require 'active_support/per_thread_registry'

WebMock.disable_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path('../fixtures', __FILE__)
  c.hook_into :webmock
  c.debug_logger

  c.default_cassette_options = {
    record:             :new_episodes,
    match_requests_on:  [:method, :uri, :headers]
  }
end

CACHE_STORE = ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')

MUSICBRAINZ_CONFIG = lambda {|config|
  config.app_name    = "MusicBrainz Test"
  config.app_version = MusicBrainz::VERSION
  config.contact     = "test@inkstak.me"
}



RSpec.configure do |config|
  # config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    MusicBrainz.configure &MUSICBRAINZ_CONFIG
  end
end
