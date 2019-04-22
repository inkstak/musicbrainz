# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '#recording', vcr: { cassette_name: 'recording' } do

  let(:client)    { MusicBrainz::Client.new }
  let(:recording) { client.recording('d6243d55-bb4f-4518-9c1c-d507a5d3843a') }

  it { expect{ recording }.to_not raise_error }

  it { expect( recording                ).to be_a(MusicBrainz::Recording) }
  it { expect( recording.id             ).to eq('d6243d55-bb4f-4518-9c1c-d507a5d3843a') }
  it { expect( recording.title          ).to eq('Rot') }
  it { expect( recording.length         ).to be_an(Integer) }
  it { expect( recording.video          ).to be(nil) }
  it { expect( recording.disambiguation ).to eq('') }

  context 'not found' do
    let(:recording) { client.recording('01234567-0123-0123-0123-012345678901') }

    it { expect( recording ).to be_nil }
  end

  context 'as video' do
    let(:recording) { client.recording('1de4184d-a3a2-4f1b-9e6e-d65e649bbc74') }

    it { expect( recording.video ).to be(true) }
  end
end

RSpec.describe '#recordings', vcr: { cassette_name: 'recording' } do

  let(:client) { MusicBrainz::Client.new }

  context 'using string' do
    let(:results) { client.recordings('Devil on my shoulder') }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have_at_least(1).recording }
    it { expect( results ).to have_at_most(25).recordings }

    it { expect( results[0]        ).to be_a(MusicBrainz::Recording) }
    it { expect( results[0].title  ).to eq('Devil On My Shoulder') }
    it { expect( results[0].length ).to be_an(Integer) }
    it { expect( results[0].score  ).to eq(100) }

    context 'with limit' do
      let(:results) { client.recordings('Devil on my shoulder', limit: 2) }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).recordings }

      it { expect( results[0]       ).to be_a(MusicBrainz::Recording) }
      it { expect( results[0].title ).to eq('Devil On My Shoulder') }
      it { expect( results[0].score ).to eq(100) }
    end
  end

  context 'using indexed search' do
    let(:results) { client.recordings(q: { recording: 'State of the Union', arid: '606bf117-494f-4864-891f-09d63ff6aa4b' }) }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have(5).recordings }

    it { expect( results[0]       ).to be_a(MusicBrainz::Recording) }
    it { expect( results[0].title ).to eq('State of the Union') }
    it { expect( results[0].score ).to eq(100) }

    context 'with limit' do
      let(:results) { client.recordings(q: { recording: 'State of the Union' }, limit: 2) }

      it { expect{ results }.to_not raise_error }
      it { expect( results ).to have(2).recordings }

      it { expect( results[0]       ).to be_a(MusicBrainz::Recording) }
      it { expect( results[0].title ).to eq('State of the Union') }
      it { expect( results[0].score ).to eq(100) }
    end
  end

  context 'using browse syntax' do
    let(:results) { client.recordings(release: 'e5acb0c3-3a10-48b8-ade0-62d9db1a947b') }

    it { expect{ results }.to_not raise_error }
    it { expect( results ).to be_an(Array) }
    it { expect( results ).to have(16).recordings }

    it { expect( results[0]           ).to be_a(MusicBrainz::Recording) }
    it { expect( results.map(&:title) ).to include('Cinema') }
  end
end
