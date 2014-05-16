require 'spec_helper'

describe MusicBrainz::Client do

  around do |e|
    config_was = MusicBrainz.config
    MusicBrainz.reset_config
    e.run
    MusicBrainz.configure &config_was
  end

  around do |e|
    VCR.use_cassette('sample') { e.run }
  end

  define_method :request do
    client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
  end


  context 'without configuration' do
    let :client do
      MusicBrainz::Client.new
    end

    it { expect{ client }.to raise_error MusicBrainz::MissingConfiguration }
  end

  context 'with incomplete configuration' do
    let :client do
      MusicBrainz::Client.new do |c|
        c.request :musicbrainz,
          app_name:     "MusicBrainz Test",
          app_version:  MusicBrainz::VERSION
      end
    end

    it { expect{ client  }.to_not raise_error }
    it { expect{ request }.to raise_error MusicBrainz::InvalidConfiguration }
  end

  context 'with configuration' do
    let :client do
      MusicBrainz::Client.new do |c|
        c.request :musicbrainz,
          app_name:     "MusicBrainz Test",
          app_version:  MusicBrainz::VERSION,
          contact:      "test@inkstak.me"
      end
    end

    it { expect{ client  }.to_not raise_error }
    it { expect{ request }.to_not raise_error }
  end

  context 'with global configuration' do
    before do
      MusicBrainz.configure do |c|
        c.request :musicbrainz,
          app_name:     "MusicBrainz Test",
          app_version:  MusicBrainz::VERSION,
          contact:      "test@inkstak.me"
      end
    end

    let :client do
      MusicBrainz::Client.new
    end

    it { expect{ client  }.to_not raise_error }
    it { expect{ request }.to_not raise_error }
  end

  context 'with caching' do
    let :client do
      MusicBrainz::Client.new do |c|
        c.request :musicbrainz,
          app_name:     "MusicBrainz Test",
          app_version:  MusicBrainz::VERSION,
          contact:      "test@inkstak.me"

        c.response :caching, CACHE_STORE
      end
    end

    # VCR should raise on a 2nd request,
    # unless we cached it.

    it do
      expect{ request }.to_not raise_error
      expect{ request }.to_not raise_error
    end
  end

  # describe 'without query_interval' do
  #   it do
  #     expect{ request }.to_not raise_error
  #     expect{ request }.to_not raise_error
  #   end
  # end

  # describe 'with query_interval' do
  #   let(:client) do
  #     MusicBrainz::Client.new do |f|
  #       f.use MusicBrainz::Middleware::Interval, 0.2
  #     end
  #   end

  #   it do
  #     expect{ request }.to_not raise_error
  #     expect{ request }.to raise_error MusicBrainz::RequestIntervalTooShort
  #   end

  #   it do
  #     expect{ request }.to_not raise_error
  #     sleep 0.2
  #     expect{ request }.to_not raise_error
  #   end
  # end

  # describe 'retry' do
  #   let(:client) do
  #     MusicBrainz::Client.new do |f|
  #       f.use MusicBrainz::Middleware::Retry   , 1
  #       f.use MusicBrainz::Middleware::Interval, 0.2
  #     end
  #   end

  #   it do
  #     expect{ request }.to_not raise_error
  #     expect{ request }.to_not raise_error
  #   end
  # end
end