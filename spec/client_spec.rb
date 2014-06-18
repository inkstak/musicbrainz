require 'spec_helper'

describe MusicBrainz::Client do

  before { MusicBrainz.reset_config }
  around {|e| VCR.use_cassette('client') { e.run }} #, record: :new_episodes

  define_method(:request)           { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }
  define_method(:bad_request)       { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'unknown' }
  define_method(:throttled_request) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'throttled' }

  let(:client) { MusicBrainz::Client.new }


  context 'without configuration' do
    it { expect{ client }.to raise_error MusicBrainz::MissingConfiguration }
  end

  context 'with incomplete configuration' do
    before do
      MusicBrainz.configure do |config|
        config.app_name    = "MusicBrainz Test"
        config.app_version = MusicBrainz::VERSION
      end
    end

    it { expect{ client }.to raise_error MusicBrainz::InvalidConfiguration }
  end

  context 'with global configuration' do
    before do
      MusicBrainz.configure &MUSICBRAINZ_CONFIG
    end

    it { expect{ client  }.to_not raise_error }
    it { expect{ request }.to_not raise_error }


    # In order to test caching:
    #   VCR should raise on the 2nd request, unless we cached it
    #   . here, we check that it raises as expected
    #   . then, we'll check that nothing raises

    it do
      expect{ request }.to_not raise_error
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
      it { expect{ bad_request }.to raise_error(MusicBrainz::BadRequest, %r{#{ 'not a valid inc parameter' }}) }
    end

    context 'with request throttled' do
      it { expect{ throttled_request }.to raise_error(MusicBrainz::RequestFailed, %r{#{ 'exceeding the allowable rate limit' }}) }
    end
  end
end