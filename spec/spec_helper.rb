require 'rubygems'
require 'bundler/setup'
require 'musicbrainz'
require 'vcr'
require 'webmock/rspec'
require 'awesome_print'

WebMock.disable_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path('../fixtures', __FILE__)
  c.hook_into :webmock
  c.debug_logger
end

MusicBrainz.configure do |c|
  c.app_name       = "MusicBrainzGemTestSuite"
  c.app_version    = MusicBrainz::VERSION
  c.contact        = `git config user.email`.chomp
  c.query_interval = 0
  c.retry          = 0
end

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
