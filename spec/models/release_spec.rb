require 'spec_helper'

describe '#release' do

  around        {|e| VCR.use_cassette('release') { e.run }}
  let(:client)  { MusicBrainz::Client.new }
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


  context 'with media' do
    let(:release) { client.release '52dcdb00-c7ec-4446-b3d2-5da31833efc7', includes: %w(media) }

    it { expect( release       ).to be_a MusicBrainz::Release }
    it { expect( release.title ).to eq '45 or 46 Songs That Weren’t Good Enough to Go on Our Other Records' }

    it { expect( release.media    ).to be_an Array }
    it { expect( release.media    ).to have(2).media }

    it { expect( release.media[0]          ).to be_a MusicBrainz::Medium }
    it { expect( release.media[0].title    ).to eq 'Counting Sheep' }
    it { expect( release.media[0].position ).to eq 1 }
    it { expect( release.media[0].format   ).to eq 'CD' }
  end


  context 'with recordings' do
    let(:release) { client.release '52dcdb00-c7ec-4446-b3d2-5da31833efc7', includes: %w(recordings) }

    it { expect( release       ).to be_a MusicBrainz::Release }
    it { expect( release.title ).to eq '45 or 46 Songs That Weren’t Good Enough to Go on Our Other Records' }

    it { expect( release.media    ).to be_an Array }
    it { expect( release.media    ).to have(2).media }

    it { expect( release.media[0]          ).to be_a MusicBrainz::Medium }
    it { expect( release.media[0].title    ).to eq 'Counting Sheep' }
    it { expect( release.media[0].position ).to eq 1 }

    it { expect( release.media[0].recordings ).to be_an Array }
    it { expect( release.media[0].recordings ).to have(22).recordings }

    it { expect( release.media[0].recordings[0]              ).to be_a MusicBrainz::Recording }
    it { expect( release.media[0].recordings[0].id           ).to eq '81d740c8-caab-4890-b213-2c0eb4ab7304' }
    it { expect( release.media[0].recordings[0].title        ).to eq 'Pimps and Hookers' }
    it { expect( release.media[0].recordings[0].track_number ).to eq '1' }
    it { expect( release.media[0].recordings[0].position     ).to eq 1 }
  end
end


describe '#releases' do

  around       {|e| VCR.use_cassette('release') { e.run }}
  let(:client) { MusicBrainz::Client.new }


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
    let(:results) { client.releases release_group: '6845bbd5-6af9-3bbf-9235-d8beea55da1a' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }
    it { expect( results ).to have(5).releases }

    it { expect( results[0]           ).to be_a MusicBrainz::Release }
    it { expect( results.map(&:title) ).to include 'A Snow Capped Romance' }


    context 'with limit' do
      let(:results) { client.releases release_group: '6845bbd5-6af9-3bbf-9235-d8beea55da1a', limit: 2 }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).releases }

      it { expect( results[0] ).to be_a MusicBrainz::Release }
      it { expect( results.map(&:title) ).to include 'A Snow Capped Romance' }
    end


    context 'with media' do
      let(:results) { client.releases release_group: '6845bbd5-6af9-3bbf-9235-d8beea55da1a', includes: %w(media) }

      it { expect{ results }.to_not raise_error }

      it { expect( results[0] ).to be_a MusicBrainz::Release }

      it { expect( results[0].media    ).to be_an Array }
      it { expect( results[0].media    ).to have(1).medium }

      it { expect( results[0].media[0]        ).to be_a MusicBrainz::Medium }
      it { expect( results[0].media[0].format ).to eq 'CD' }
    end
  end
end
