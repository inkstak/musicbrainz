require 'spec_helper'

describe MusicBrainz::Client do

  let(:client) { MusicBrainz::Client.new }

  describe '#release_group' do
    around do |e|
      VCR.use_cassette('release_group/nevermind', record: :new_episodes) { e.run }
    end

    let(:release) { client.release_group '1b022e01-4da6-387b-8658-8678046e4cef' }

    it { expect{ release }.to_not raise_error }

    it { expect( release    ).to be_a MusicBrainz::ReleaseGroup }
    it { expect( release.id ).to eq '1b022e01-4da6-387b-8658-8678046e4cef' }

    it { expect( release.title         ).to eq 'Nevermind' }
    it { expect( release.type          ).to eq 'Album' }
    it { expect( release.release_date  ).to eq '1991-09-23' }
    it { expect( release.urls          ).to be_nil }

    context 'with urls' do
      let(:release) { client.release_group '1b022e01-4da6-387b-8658-8678046e4cef', includes: 'url-rels' }

      it { expect( release.urls ).to be_a Hash }
      it { expect( release.urls['wikipedia'] ).to be_a String }
      it { expect( release.urls['review']    ).to be_an Array }
    end
  end

  describe '#release_groups' do
    around do |e|
      VCR.use_cassette('release_group/search', record: :new_episodes) { e.run }
    end

    let(:results) { client.release_groups 'nevermind' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }

    it { expect( results ).to have_at_least(1).release }
    it { expect( results ).to have_at_most(10).releases }

    it { expect( results[0]       ).to be_a MusicBrainz::ReleaseGroup }
    it { expect( results[0].id    ).to eq '1b022e01-4da6-387b-8658-8678046e4cef' }
    it { expect( results[0].score ).to eq 100 }

    context 'with a limit' do
      let(:results) { client.release_groups 'nevermind', limit: 2 }

      it { expect( results ).to have(2).releases }

      it { expect( results[0]       ).to be_a MusicBrainz::ReleaseGroup }
      it { expect( results[0].id    ).to eq '1b022e01-4da6-387b-8658-8678046e4cef' }
      it { expect( results[0].score ).to eq 100 }
    end

    context 'with an artist' do
      let(:results) { client.release_groups artist: 'Nirvana' }

      it { expect( results    ).to have(10).releases }
      it { expect( results[0] ).to be_a MusicBrainz::ReleaseGroup }
    end
  end

  describe '#browse_release_groups' do
    around do |e|
      VCR.use_cassette('release_group/browse', record: :new_episodes) { e.run }
    end

    context 'without linked arguments' do
      let(:releases) { client.browse_release_groups }

      it { expect{ releases }.to raise_error(MusicBrainz::InvalidRequest) }
    end

    context 'with an artist' do
      let(:releases) { client.browse_release_groups artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

      it { expect( releases ).to have(25).releases }
      it { expect( releases[0] ).to be_a MusicBrainz::ReleaseGroup }
    end
  end
end