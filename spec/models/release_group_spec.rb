# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '#release_group', vcr: { cassette_name: 'release_group' } do
  let(:client)  { MusicBrainz::Client.new }
  let(:release) { client.release_group('fb3770f6-83fb-32b7-85c4-1f522a92287e') }

  it { expect{ release }.to_not raise_error }

  it { expect( release                    ).to be_a(MusicBrainz::ReleaseGroup) }
  it { expect( release.id                 ).to eq('fb3770f6-83fb-32b7-85c4-1f522a92287e') }
  it { expect( release.title              ).to eq('MTV Unplugged in New York') }
  it { expect( release.primary_type       ).to eq('Album') }
  it { expect( release.secondary_types    ).to eq(['Live']) }
  it { expect( release.first_release_date ).to eq('1994-11-01') }
  it { expect( release.disambiguation     ).to eq('') }

  it { expect{ release.urls  }.to raise_error(NoMethodError) }
  it { expect{ release.score }.to raise_error(NoMethodError) }

  context 'not found' do
    let(:release) { client.release_group('01234567-0123-0123-0123-012345678901') }

    it { expect( release ).to be_nil }
  end

  context 'with urls' do
    let(:release) { client.release_group('fb3770f6-83fb-32b7-85c4-1f522a92287e', includes: %w[url-rels]) }

    it { expect( release.urls ).to be_a(Hash) }
    it { expect( release.urls['wikipedia'] ).to be_a(String) }
    it { expect( release.urls['wikipedia'] ).to eq('http://en.wikipedia.org/wiki/MTV_Unplugged_in_New_York') }
  end
end

RSpec.describe '#release_groups', vcr: { cassette_name: 'release_group' } do
  let(:client) { MusicBrainz::Client.new }

  context 'using string' do
    let(:results) { client.release_groups('MTV Unplugged in New York') }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have_at_least(1).release }
    it { expect( results ).to have_at_most(25).releases }

    it { expect( results[0]                 ).to be_a(MusicBrainz::ReleaseGroup) }
    it { expect( results[0].title           ).to eq('MTV Unplugged in New York') }
    it { expect( results[0].primary_type    ).to eq('Album') }
    it { expect( results[0].secondary_types ).to eq(['Live']) }
    it { expect( results[0].score           ).to eq(100) }

    context 'with limit' do
      let(:results) { client.release_groups('MTV Unplugged in New York', limit: 2) }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).releases }

      it { expect( results[0]       ).to be_a(MusicBrainz::ReleaseGroup) }
      it { expect( results[0].title ).to eq('MTV Unplugged in New York') }
      it { expect( results[0].score ).to eq(100) }
    end
  end

  context 'using indexed search' do
    let(:results) { client.release_groups(q: { release_group: 'Bleach', arid: '5b11f4ce-a62d-471e-81fc-a69a8278c7da', status: 'official' }) }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have(1).release }

    it { expect( results[0]       ).to be_a(MusicBrainz::ReleaseGroup) }
    it { expect( results[0].title ).to eq('Bleach') }
    it { expect( results[0].score ).to eq(100) }

    context 'with limit' do
      let(:results) { client.release_groups(q: { release_group: 'Bleach' }, limit: 2) }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).releases }

      it { expect( results[0]       ).to be_a(MusicBrainz::ReleaseGroup) }
      it { expect( results[0].title ).to eq('Bleach') }
      it { expect( results[0].score ).to eq(100) }
    end
  end

  context 'using browse syntax' do
    let(:results) { client.release_groups(artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da') }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have(25).releases }

    it { expect( results[0]           ).to be_a(MusicBrainz::ReleaseGroup) }
    it { expect( results.map(&:title) ).to include('Nevermind') }

    context 'with limit' do
      let(:results) { client.release_groups(artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da', limit: 2) }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).releases }

      it { expect( results[0] ).to be_a(MusicBrainz::ReleaseGroup) }
    end
  end
end
