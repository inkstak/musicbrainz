# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MusicBrainz::Client, vcr: { cassette_name: 'client' } do
  before       { MusicBrainz.reset_config }
  let(:client) { MusicBrainz::Client.new }

  define_method(:request)           { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }
  define_method(:bad_request)       { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'unknown' }
  define_method(:throttled_request) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'throttled' }

  context 'without configuration' do
    it { expect{ client }.to raise_error MusicBrainz::MissingConfiguration }
  end

  context 'with incomplete configuration' do
    before do
      MusicBrainz.configure do |config|
        config.app_name    = 'MusicBrainz Test'
        config.app_version = MusicBrainz::VERSION
      end
    end

    it { expect{ client }.to raise_error MusicBrainz::InvalidConfiguration }
  end

  context 'with global configuration' do
    before do
      MusicBrainz.configure(&MUSICBRAINZ_CONFIG)
    end

    it { expect{ client  }.to_not raise_error }
    it { expect{ request }.to_not raise_error }

    # In order to test caching:
    #   VCR should raise on the 2nd request, unless we cached it
    #   . here, we check that it raises as expected
    #   . then, we'll check that nothing raises

    it do
      expect{ request }.to_not raise_error
      VCR.eject_cassette
      expect{ request }.to raise_error(VCR::Errors::UnhandledHTTPRequestError)
    end

    context 'with caching' do
      let :client do
        MusicBrainz::Client.new do |connection|
          connection.response :caching, CACHE_STORE
        end
      end

      it do
        expect{ request }.to_not raise_error
        expect{ request }.to_not raise_error
      end
    end

    context 'with bad request' do
      it { expect{ bad_request }.to raise_error(MusicBrainz::BadRequest, /not a valid inc parameter/) }
    end

    # You must edit the VCR cassette
    # to return a Service Unavailable instead of a Bad Request:
    #   code: 503
    #   message: Service Unavailable

    context 'with request throttled' do
      it { expect{ throttled_request }.to raise_error(MusicBrainz::RequestFailed, /exceeding the allowable rate limit/) }
    end
  end
end
