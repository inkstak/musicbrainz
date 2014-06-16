require 'spec_helper'

describe MusicBrainz::Client do

  before do
    MusicBrainz.configure &MUSICBRAINZ_CONFIG
  end

  let :client  do
    MusicBrainz::Client.new
  end


  describe '#artist' do
    around do |e|
      VCR.use_cassette('artist/nirvana', record: :new_episodes) { e.run }
    end

    let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

    it { expect{ artist }.to_not raise_error }

    it { expect( artist    ).to be_a MusicBrainz::Artist }
    it { expect( artist.id ).to eq '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

    it { expect( artist.name          ).to eq 'Nirvana' }
    it { expect( artist.type          ).to eq 'Group' }
    it { expect( artist.country       ).to eq 'US' }
    it { expect( artist.date_begin    ).to eq '1988-01' }
    it { expect( artist.urls          ).to be_nil }
    it { expect( artist.relationships ).to be_nil }

    context 'with unknown UID' do
      let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-123456789abc' }

      it { expect( artist ).to be_nil }
    end

    context 'with urls' do
      let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'url-rels' }

      it { expect( artist.urls ).to be_a Hash }
      it { expect( artist.urls['wikipedia']      ).to be_a String }
      it { expect( artist.urls['social network'] ).to be_an Array }
    end

    context 'with relationships' do
      let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'artist-rels' }

      it { expect( artist.relationships    ).to be_an Array }
      it { expect( artist.relationships[0] ).to be_a MusicBrainz::Relationship }
    end

    describe '#release_groups' do
      let(:releases) { artist.release_groups }

      it { expect( releases    ).to have(25).releases }
      it { expect( releases[0] ).to be_a MusicBrainz::ReleaseGroup }
    end
  end

  describe '#artists' do
    around do |e|
      VCR.use_cassette('artist/search', record: :new_episodes) { e.run }
    end

    let(:results) { client.artists 'Nirvana' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }

    it { expect( results ).to have_at_least(1).artist }
    it { expect( results ).to have_at_most(10).artists }

    it { expect( results[0]       ).to be_a MusicBrainz::Artist }
    it { expect( results[0].id    ).to eq '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }
    it { expect( results[0].score ).to eq 100 }

    context 'with a limit' do
      let(:results) { client.artists 'Nirvana', limit: 2 }

      it { expect( results ).to have(2).artists }

      it { expect( results[0]    ).to be_a MusicBrainz::Artist }
      it { expect( results[0].id ).to eq '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }
      it { expect( results[0].score ).to eq 100 }
    end
  end
end
