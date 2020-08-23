# MusicBrainz

A simple client for the [MusicBrainz](http://musicbrainz.org) web service, largely inspired by the [musicbrainz gem](https://github.com/localhots/musicbrainz) by [Gregory Eremin](https://github.com/localhots)

[![Build Status](https://travis-ci.org/inkstak/musicbrainz.svg)](https://travis-ci.org/inkstak/musicbrainz)


## Installation

Add these line to your application's Gemfile:

```ruby
gem 'musicbrainz', github: 'inkstak/musicbrainz', tag: '1.1.0'
```

### Requirements

Ruby >= 2.5 required.


## Usage

```ruby
client = MusicBrainz::Client.new

search = client.artists 'Nirvana'
artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
```

### Configuration

You first need to setup a global configuration:

```ruby
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


#### Lookup requests

Lookup requests return a single item.
The name of the method is the singular name of the asset.

```ruby
client.artist '67f66c07-6e61-4026-ade5-7e782fad3a5d'
# => #<MusicBrainz::Artist>
```

Lookup requests support subqueries & relationships as described in [API manual](http://musicbrainz.org/doc/Development/XML_Web_Service/Version_2#Lookups)
through the `:includes` option.

```ruby
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'url-rels'
# => #<MusicBrainz::Artist urls: [...]>
```


#### Search request

Search requests use the plural named method to return an array of assets.

```ruby
client.artists 'Foo Fighters'
# => [#<MusicBrainz::Artist>, #<MusicBrainz::Artist>, ...]
```


Search requests support [Indexed Search Syntax](http://musicbrainz.org/doc/Indexed_Search_Syntax).

```ruby
client.artists '30 seconds'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">, #<MusicBrainz::Artist name: "30 Seconds Over Tokyo">, #<MusicBrainz::Artist name: "30 Seconds GO!">, ...]

client.artists q: { artist: '30 seconds to mars' }
# => []

client.artists q: { alias: '30 seconds to mars' }
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">]

client.artists q: 'artist:"30 seconds to mars" OR alias:"30 seconds to mars"'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">]
```


By default, search params are linked by the AND operator.
You can keep the hash syntax by passing an operator:

```ruby
client.artists q: { artist: '30 seconds to mars', alias: '30 seconds to mars' }
# => []

client.artists q: { artist: '30 seconds to mars', alias: '30 seconds to mars' }, operator: 'OR'
# => [#<MusicBrainz::Artist name: "Thirty Seconds to Mars">]
```


You can also perform a [browse request](http://musicbrainz.org/doc/Development/XML_Web_Service/Version_2#Browse)
to return all the entities directly linked to another.

Such requests only work with a valid MBID.

```ruby
client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138'
# => [#<MusicBrainz::Artist name: "Dick Dale and His Del-Tones">, #<MusicBrainz::Artist name: "Kool & The Gang">, #<MusicBrainz::Artist name: "Al Green">, ...]
```


*Be careful:* some attributes available in lookup requests may be missing in search results.


#### Examples

##### Artists

```ruby
# Artist lookup
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'url-rels'
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: %w(url-rels artist-rels)

# Artists search
client.artists 'Nirvana'
client.artists 'Nirvana', limit: 10

# Artists indexed search
client.artists q: { artist: 'Nirvana', country: 'se' }
client.artists q: { artist: '30 seconds to mars', alias: '30 seconds to mars' }, operator: 'OR'
client.artists q: { tag: 'Punk' }, limit: 2

# Artists browse
client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138'
```

##### Release groups

```ruby
# Release lookup
client.release_group 'fb3770f6-83fb-32b7-85c4-1f522a92287e'
client.release_group 'fb3770f6-83fb-32b7-85c4-1f522a92287e', includes: %w(url-rels)

# Releases search
client.release_groups 'MTV Unplugged in New York'
client.release_groups q: { release_group: 'Bleach', arid: '5b11f4ce-a62d-471e-81fc-a69a8278c7da', status: 'official' }

# Releases browse
client.release_groups artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
```


##### Releases


```ruby
# Release lookup
client.release 'c1ef70f1-f88d-311f-87d4-b2766d8ca0ae'
client.release 'c1ef70f1-f88d-311f-87d4-b2766d8ca0ae', includes: %w(recordings)

# Releases search
client.releases 'MTV Unplugged in New York'
client.releases q: { release: 'Bleach', rgid: 'f1afec0b-26dd-3db5-9aa1-c91229a74a24' }

# Releases browse
client.releases artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
client.releases release_group: '6845bbd5-6af9-3bbf-9235-d8beea55da1a'
```


##### Records

```ruby
# Record lookup
client.recording 'd6243d55-bb4f-4518-9c1c-d507a5d3843a'

# Records search
client.recordings 'Devil on my shoulder'
client.recordings 'Devil on my shoulder', limit: 2
client.recordings q: { recording: 'State of the Union', arid: '606bf117-494f-4864-891f-09d63ff6aa4b' }}

# Records browse
client.recordings release: 'e5acb0c3-3a10-48b8-ade0-62d9db1a947b' }
```


### Middlewares

The `MusicBrainz::Client` uses Faraday middlewares to control requests cycle.

#### Caching

Take a look at [faraday_middleware](https://github.com/lostisland/faraday_middleware).  
You may implement simple response body caching like that:

```ruby
client = MusicBrainz::Client.new do |c|
  c.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
end
```

Inside a Rails app, it will look like:

```ruby
client = MusicBrainz::Client.new do |c|
  c.response :caching, Rails.cache
end
```

#### Throttler

To ensure your client won't spam the API as required by [MusicBrainz good practices](http://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting#How_can_I_be_a_good_citizen_and_be_smart_about_using_the_Web_Service.3F),
this gem provides a Throttler middleware that requires an interval between each request.
This middleware needs cache.

```ruby
client = MusicBrainz::Client.new do |c|
  f.request :throttler, Rails.cache, interval: 1.second
end
```


## Contributing

1. Fork the [repository](https://github.com/inkstak/musicbrainz)
2. Create a feature branch
4. Ensure tests & Rubocop are passing
5. Create a pull request

### Running tests & analyzing code

RSpec & Rubocop can be launched through guard:

```
bundle exec guard
```

### Console

To quickly run a console:

```
bundle exec irb -r './console.rb'
```


## License & credits

Copyright (c) 2014 Savater Sebastien.  
See [LICENSE](https://github.com/inkstak/musicbrainz/blob/master/LICENSE) for further details.

Largely inspired by the [musicbrainz gem](https://github.com/localhots/musicbrainz) by [Gregory Eremin](https://github.com/localhots)

Contributors:
* James [@PoweredByRobots](https://github.com/PoweredByRobots)
* Jerimiah Milton [@OBCENEIKON](https://github.com/OBCENEIKON)
* Pat Allan [@pat](https://github.com/pat)
