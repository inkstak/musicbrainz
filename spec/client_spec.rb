require 'spec_helper'

describe MusicBrainz::Client do

  let(:client) { MusicBrainz::Client.new }
  define_method(:request) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

  around do |e|
    VCR.use_cassette('sample', record: :new_episodes) { e.run }
  end

  describe 'without query_interval' do
    it do
      expect{ request }.to_not raise_error
      expect{ request }.to_not raise_error
    end
  end

  describe 'with query_interval' do
    let(:client) do
      MusicBrainz::Client.new do |f|
        f.use MusicBrainz::Middleware::Interval, 0.2
      end
    end

    it do
      expect{ request }.to_not raise_error
      expect{ request }.to raise_error MusicBrainz::RequestIntervalTooShort
    end

    it do
      expect{ request }.to_not raise_error
      sleep 0.2
      expect{ request }.to_not raise_error
    end
  end

  describe 'retry' do
    let(:client) do
      MusicBrainz::Client.new do |f|
        f.use MusicBrainz::Middleware::Retry   , 1
        f.use MusicBrainz::Middleware::Interval, 0.2
      end
    end

    it do
      expect{ request }.to_not raise_error
      expect{ request }.to_not raise_error
    end
  end
end