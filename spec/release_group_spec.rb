require 'spec_helper'

describe MusicBrainz::Client do

  before { MusicBrainz.configure &MUSICBRAINZ_CONFIG }
  around {|e| VCR.use_cassette('release_group', record: :new_episodes) { e.run }}

  let(:client) { MusicBrainz::Client.new }


  describe '#release_group' do
    let(:release) { client.release_group 'fb3770f6-83fb-32b7-85c4-1f522a92287e' }

    it { expect{ release }.to_not raise_error }

    it { expect( release                    ).to be_a MusicBrainz::ReleaseGroup }
    it { expect( release.id                 ).to eq 'fb3770f6-83fb-32b7-85c4-1f522a92287e' }
    it { expect( release.title              ).to eq 'MTV Unplugged in New York' }
    it { expect( release.type               ).to eq 'Live' }
    it { expect( release.primary_type       ).to eq 'Album' }
    it { expect( release.secondary_types    ).to eq ['Live'] }
    it { expect( release.first_release_date ).to eq '1994-11-01' }
    it { expect( release.disambiguation     ).to eq '' }

    it { expect{ release.urls               }.to raise_error }
    it { expect{ release.score              }.to raise_error }


    context 'not found' do
      let(:release) { client.release_group '01234567-0123-0123-0123-012345678901' }
      it { expect( release ).to be_nil }
    end


    describe '#urls' do
      let(:release) { client.release_group 'fb3770f6-83fb-32b7-85c4-1f522a92287e', includes: %w(url-rels) }

      it { expect( release.urls ).to be_a Hash }
      it { expect( release.urls['wikipedia'] ).to be_a String }
      it { expect( release.urls['wikipedia'] ).to eq 'http://en.wikipedia.org/wiki/MTV_Unplugged_in_New_York' }
    end
  end


  describe '#release_groups' do
    let(:results) { client.release_groups 'MTV Unplugged in New York' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }

    it { expect( results ).to have_at_least(1).release }
    it { expect( results ).to have_at_most(10).releases }

    it { expect( results[0]                    ).to be_a MusicBrainz::ReleaseGroup }
    it { expect( results[0].id                 ).to eq 'fb3770f6-83fb-32b7-85c4-1f522a92287e' }
    it { expect( results[0].title              ).to eq 'MTV Unplugged in New York' }
    it { expect( results[0].type               ).to eq 'Live' }

    it { expect( results[0].score ).to eq 100 }


    context 'with a limit' do
      let(:results) { client.release_groups 'MTV Unplugged in New York' 'Nirvana', limit: 2 }

      it { expect( results ).to have(2).releases }

      it { expect( results[0]       ).to be_a MusicBrainz::ReleaseGroup }
      it { expect( results[0].id    ).to eq 'fb3770f6-83fb-32b7-85c4-1f522a92287e' }
      it { expect( results[0].score ).to eq 100 }
    end


    context 'with an artist' do
      let(:results) { client.release_groups artist: 'Nirvana' }

      it { expect( results ).to have_at_least(1).release }
      it { expect( results ).to have_at_most(10).releases }

      it { expect( results[0] ).to be_a MusicBrainz::ReleaseGroup }
    end
  end
end