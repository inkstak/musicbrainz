require 'spec_helper'

describe MusicBrainz::Client do

  let(:client) { MusicBrainz::Client.new }
  define_method(:request) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

  around do |e|
    VCR.use_cassette('sample', record: :new_episodes) { e.run }
  end

  describe 'query_interval' do
    before { MusicBrainz.config.query_interval = 0.5 }
    after  { MusicBrainz.config.query_interval = 0 }

    it do
      expect{ request }.to_not raise_error
      expect{ request }.to raise_error MusicBrainz::RequestIntervalTooShort

      sleep 0.5
      expect{ request }.to_not raise_error
    end
  end

  describe 'query_interval at 0' do
    it do
      expect{ request }.to_not raise_error
      expect{ request }.to_not raise_error
    end
  end

  describe 'retry' do
    before { MusicBrainz.config.query_interval = 0.5 }
    before { MusicBrainz.config.retry          = 1 }

    after  { MusicBrainz.config.query_interval = 0 }
    after  { MusicBrainz.config.retry          = 0 }

    it do
      expect{ request }.to_not raise_error
      expect{ request }.to_not raise_error
    end
  end
end