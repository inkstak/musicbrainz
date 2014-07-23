# MusicBrainz

A simple client for the [MusicBrainz](http://musicbrainz.org) web service, largely inspired by the [musicbrainz gem](https://github.com/localhots/musicbrainz) by [Gregory Eremin](https://github.com/localhots)

It uses through a threadsafe client the [new JSON API](http://wiki.musicbrainz.org/Development/JSON_Web_Service) (currently in development), implements subqueries as an option and allows you to use `Rails.cache` or any cache design you have implemented.

[![Build Status](https://travis-ci.org/inkstak/musicbrainz.svg)](https://travis-ci.org/inkstak/musicbrainz)


## Installation

Add this line to your application's Gemfile:

```
gem 'musicbrainz', github: 'inkstak/musicbrainz'
```


### Requirements

Ruby version 2.x required.


## Usage

```
client = MusicBrainz::Client.new

search = client.artists 'Nirvana'
artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
```

### Configuration

You first need to setup a global configuration:

```
MusicBrainz.configure do |c|
  c.app_name    = 'MyApp'
  c.app_version = '0.0.1.alpha'
  c.contact     = 'john.doe@my.app'
end

client = MusicBrainz::Client.new
```

The `app_name`, `app_version` & `contact` values are required before running any requests accordingly to the [MusicBrainz best practises](http://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting#How_can_I_be_a_good_citizen_and_be_smart_about_using_the_Web_Service.3F).

You may also use middlewares to avoid being blocked or throttled, to implement caching or instrumentation.


### Requests

You can request following assets:

* artists
* release_groups
* releases
* recordings


For each assets you can perform:

* a search request (plural named method)
* a lookup request (singular method)

Example:

```
client = MusicBrainz::Client.new

client.artists 'Foo Fighters'
# => [#<MusicBrainz::Artist id: "67f66c07-6e61-4026-ade5-7e782fad3a5d", name: "Foo Fighters">,
#    #<MusicBrainz::Artist id: "35177a1d-d6b7-4f8e-81bf-a9e81613aa99", name: "Foo">,
#    #<MusicBrainz::Artist id: "9b7acf27-8cf7-4e15-9445-22daac99b372", name: "Fighters", ...]

client.artist '67f66c07-6e61-4026-ade5-7e782fad3a5d'
# => #<MusicBrainz::Artist id: "67f66c07-6e61-4026-ade5-7e782fad3a5d", name: "Foo Fighters">
```

Search requests support [Indexed_Search_Syntax](http://musicbrainz.org/doc/Indexed_Search_Syntax)

```
client.artists '30 seconds to mars'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">,
#    #<MusicBrainz::Artist name: "30 Seconds Over Tokyo">,
#    #<MusicBrainz::Artist name: "30 Seconds GO!">, ...]

client.artists artist: '30 seconds to mars'
# => []

client.artists alias: '30 seconds to mars'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">]

api.artists 'artist:"30 seconds to mars" OR alias:"30 seconds to mars"'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">]
```


Lookup requests support subqueries & relationships as described in [API manual](http://musicbrainz.org/doc/Development/XML_Web_Service/Version_2#Lookups) through the `:includes` option.

```
artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'url-rels'
```


#### Artists

```
search = client.artists 'Foo Fighters'
artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: %w(url-rels artist-rels)

artist.release_groups
```

Available `includes` options:

* url-rels
* artist-rels


### Middlewares

The `MusicBrainz::Client` uses Faraday middlewares to control requests cycle.


#### Query Interval & Retry

To be sure your client won't spam the API accordingly to the [MusicBrainz best practises](http://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting#How_can_I_be_a_good_citizen_and_be_smart_about_using_the_Web_Service.3F)

```
client = MusicBrainz::Client.new do |c|
  c.request :retry, max: 2, interval: 1
end
```

#### Caching

Take a look at [faraday_middleware](https://github.com/lostisland/faraday_middleware).  
You may implement simple response body caching like that:

```
client = MusicBrainz::Client.new do |c|
  c.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
end
```

Inside a Rails app, it will look like:

```
client = MusicBrainz::Client.new do |c|
  c.response :caching, Rails.cache
end
```
