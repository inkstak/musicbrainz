require 'spec_helper'

describe MusicBrainz::Client do

  before { MusicBrainz.configure &MUSICBRAINZ_CONFIG }
  around {|e| VCR.use_cassette('release', record: :new_episodes) { e.run }}

  let(:client) { MusicBrainz::Client.new }


  describe '#release' do
    let(:release) { client.release 'c1ef70f1-f88d-311f-87d4-b2766d8ca0ae' }

    it { expect{ release }.to_not raise_error }

    it { expect( release                    ).to be_a MusicBrainz::Release }
    it { expect( release.id                 ).to eq 'c1ef70f1-f88d-311f-87d4-b2766d8ca0ae' }
    it { expect( release.title              ).to eq 'A Snow Capped Romance' }
    it { expect( release.country            ).to eq 'US' }
    it { expect( release.date               ).to eq '2004-03-16' }
    it { expect( release.status             ).to eq 'Official' }
    it { expect( release.disambiguation     ).to eq '' }

    it { expect{ release.urls               }.to raise_error }
    it { expect{ release.score              }.to raise_error }


    context 'not found' do
      let(:release) { client.release '01234567-0123-0123-0123-012345678901' }
      it { expect( release ).to be_nil }
    end
  end


  describe '#releases' do
    context 'using string' do
      let(:results) { client.releases 'MTV Unplugged in New York' }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to be_an Array }

      it { expect( results ).to have_at_least(1).release }
      it { expect( results ).to have_at_most(25).releases }

      it { expect( results[0]                 ).to be_a MusicBrainz::Release }
      it { expect( results[0].title           ).to eq 'MTV Unplugged in New York' }
      it { expect( results[0].status          ).to eq 'Official' }
      it { expect( results[0].score           ).to eq 100 }


      context 'with limit' do
        let(:results) { client.releases 'MTV Unplugged in New York', limit: 2 }

        it { expect{ results }.to_not raise_error }
        it { expect( results ).to have(2).releases }

        it { expect( results[0]       ).to be_a MusicBrainz::Release }
        it { expect( results[0].title ).to eq 'MTV Unplugged in New York' }
        it { expect( results[0].score ).to eq 100 }
      end
    end


    context 'using indexed search' do
      let(:results) { client.releases q: { release: 'Bleach', rgid: 'f1afec0b-26dd-3db5-9aa1-c91229a74a24' }}

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to be_an Array }
      it { expect( results ).to have(15).releases }

      it { expect( results[0]       ).to be_a MusicBrainz::Release }
      it { expect( results[0].title ).to eq 'Bleach' }
      it { expect( results[0].score ).to eq 100 }


      context 'with limit' do
        let(:results) { client.releases q: { release: 'Bleach' }, limit: 2 }

        it { expect{ results }.to_not raise_error }
        it { expect( results ).to have(2).releases }

        it { expect( results[0]       ).to be_a MusicBrainz::Release }
        it { expect( results[0].title ).to eq 'Bleach' }
        it { expect( results[0].score ).to eq 100 }
      end
    end


    context 'using browse syntax' do
      let(:results) { client.releases artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to be_an Array }
      it { expect( results ).to have(25).releases }

      it { expect( results[0]           ).to be_a MusicBrainz::Release }
      it { expect( results.map(&:title) ).to include 'Nevermind' }


      context 'with limit' do
        let(:results) { client.releases artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da', limit: 2 }

        it { expect{ results }.to_not raise_error }
        it { expect( results ).to have(2).releases }

        it { expect( results[0] ).to be_a MusicBrainz::Release }
      end
    end
  end
end