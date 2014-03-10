# Cover Art

A new client for the [MusicBrainz](http://musicbrainz.org) web service.
This gem is a complete rewrite of the [musicbrainz gem](https://github.com/localhots/musicbrainz) by [Gregory Eremin](https://github.com/localhots)

It uses the new (wip) JSON API and includes more subqueries.

### Ruby Version

Ruby version 2.x required.

### Installation

Add the line to your Gemfile

    gem 'musicbrainz', github: 'inkstak/musicbrainz'


### Usage

Read the [JSON API manual](http://wiki.musicbrainz.org/Cover_Art_Archive/API)

    require 'musicbrainz'
    client = MusicBrainz::Client.new


#### Artists

    client.artists.search 'Foo Fighters'
