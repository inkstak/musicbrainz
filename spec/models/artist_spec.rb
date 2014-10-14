require 'spec_helper'

describe '#artist' do

  around       {|e| VCR.use_cassette('artist') { e.run }}
  let(:client) { MusicBrainz::Client.new }
  let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }


  it { expect{ artist }.to_not raise_error }

  it { expect( artist                 ).to be_a MusicBrainz::Artist }
  it { expect( artist.id              ).to eq '5b11f4ce-a62d-471e-81fc-a69a8278c7da' }
  it { expect( artist.name            ).to eq 'Nirvana' }
  it { expect( artist.sort_name       ).to eq 'Nirvana' }
  it { expect( artist.type            ).to eq 'Group' }
  it { expect( artist.country         ).to eq 'US' }
  it { expect( artist.disambiguation  ).to eq '90s US grunge band' }
  it { expect( artist.ipis            ).to eq [] }

  it { expect( artist.date_begin      ).to eq '1988-01' }
  it { expect( artist.date_end        ).to eq '1994-04-05' }

  it { expect( artist.area            ).to be_a MusicBrainz::Area }
  it { expect( artist.begin_area      ).to be_a MusicBrainz::Area }
  it { expect( artist.end_area        ).to be_nil }

  it { expect{ artist.urls            }.to raise_error }
  it { expect{ artist.relationships   }.to raise_error }
  it { expect{ artist.score           }.to raise_error }


  context 'not found' do
    let(:artist) { client.artist '01234567-0123-0123-0123-012345678901' }

    it { expect{ artist }.to_not raise_error }
    it { expect( artist ).to be_nil }
  end


  context 'with urls' do
    let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: %w(url-rels) }

    it { expect( artist.urls                   ).to be_a Hash }
    it { expect( artist.urls['wikipedia']      ).to be_a String }
    it { expect( artist.urls['social network'] ).to be_an Array }

    it { expect( artist.urls['wikipedia']      ).to eq 'http://en.wikipedia.org/wiki/Nirvana_(band)' }
    it { expect( artist.urls['social network'] ).to include 'http://www.last.fm/music/Nirvana' }
  end


  context 'with relationships' do
    let(:artist) { client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: %w(artist-rels) }

    it { expect( artist.relationships           ).to be_an Array }
    it { expect( artist.relationships[0]        ).to be_a MusicBrainz::Relationship }
    it { expect( artist.relationships[0].artist ).to be_a MusicBrainz::Artist }
  end
end


describe '#artists' do

  around       {|e| VCR.use_cassette('artist') { e.run }}
  let(:client) { MusicBrainz::Client.new }


  context 'using string' do
    let(:results) { client.artists 'Nirvana' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }
    it { expect( results ).to have_at_least(1).artist }
    it { expect( results ).to have_at_most(25).artists }

    it { expect( results[0]         ).to be_a MusicBrainz::Artist }
    it { expect( results[0].name    ).to eq 'Nirvana' }
    it { expect( results[0].score   ).to eq 100 }


    context 'with limit' do
      let(:results) { client.artists 'Nirvana', limit: 2 }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).artists }

      it { expect( results[0]       ).to be_a MusicBrainz::Artist }
      it { expect( results[0].name  ).to eq 'Nirvana' }
      it { expect( results[0].score ).to eq 100 }
    end
  end


  context 'using indexed search' do
    let(:results) { client.artists q: { artist: 'Nirvana', country: 'fi' }}

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }
    it { expect( results ).to have(1).artist }

    it { expect( results[0]                ).to be_a MusicBrainz::Artist }
    it { expect( results[0].name           ).to eq 'Nirvana' }
    it { expect( results[0].score          ).to eq 100 }
    it { expect( results[0].disambiguation ).to eq "Early 1980's Finnish punk band" }


    context 'with limit' do
      let(:results) { client.artists q: { artist: 'Nirvana' }, limit: 2 }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).artists }

      it { expect( results[0]       ).to be_a MusicBrainz::Artist }
      it { expect( results[0].name  ).to eq 'Nirvana' }
      it { expect( results[0].score ).to eq 100 }
    end
  end


  context 'using browse syntax' do
    let(:results) { client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138' }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an Array }
    it { expect( results ).to have(15).artist }

    it { expect( results[0]          ).to be_a MusicBrainz::Artist }
    it { expect( results.map(&:name) ).to include 'Dick Dale and His Del-Tones' }


    context 'with limit' do
      let(:results) { client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138', limit: 2 }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).artists }

      it { expect( results[0] ).to be_a MusicBrainz::Artist }
    end
  end
end
