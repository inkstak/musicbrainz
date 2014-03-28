# MusicBrainz

A simple client for the [MusicBrainz](http://musicbrainz.org) web service, largely inspired by the [musicbrainz gem](https://github.com/localhots/musicbrainz) by [Gregory Eremin](https://github.com/localhots)

It uses the new JSON API (currently in beta) and implements subqueries as an option.


## Installation

Add this line to your application's Gemfile:

    gem 'musicbrainz', github: 'inkstak/musicbrainz'


### Requirements

Ruby version 2.x required.



## Usage

    client = MusicBrainz::Client.new

    search = client.artists 'Foo Fighters'
    artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'




### Configuration

You can setup a global configuration:

    MusicBrainz.configure do |c|
      c.app_name    = 'MyApp'
    c.app_version = '0.0.1.alpha'
      c.contact     = 'john.doe@my.app'
    end

  client = MusicBrainz::Client.new


... or a threadsafe one:

    client = MusicBrainz::Client.new do |c|
      c.app_name    = 'MyApp'
    c.app_version = '0.0.1.alpha'
      c.contact     = 'john.doe@my.app'
    end


The `app_name`, `app_version` & `contact` values are required before running any requests accordingly to the [MusicBrainz best practises](http://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting#How_can_I_be_a_good_citizen_and_be_smart_about_using_the_Web_Service.3F).

You may also use provided middlewares to avoid being blocked or throttled, or use Faraday middlewares to implement caching or instrumentation.


### Requests

Take a look to [JSON API manual](http://wiki.musicbrainz.org/Cover_Art_Archive/API).


#### Artists

    client = MusicBrainz::Client.new

    search = client.artists 'Foo Fighters'
    artist = client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da', includes: 'url-rels'



### Middlewares

The `MusicBrainz::Client` uses Faraday middlewares to control requests cycle.


#### Query Interval

Be sure your client won't spam the API

    client = MusicBrainz::Client.new do |c|
      c.use MusicBrainz::Middleware::Interval, 0.2
    end


#### Retry

Retry middleware works along the Interval middelware.

    client = MusicBrainz::Client.new do |c|
      c.use MusicBrainz::Middleware::Retry   , 1
      c.use MusicBrainz::Middleware::Interval, 0.2
    end

<b>Important:</b> the Retry middleware must be call <b>before</b> the Interval


#### Caching

Take a look at [faraday_middleware](https://github.com/lostisland/faraday_middleware).
You may implement simple response body caching like that:

    client = MusicBrainz::Client.new do |c|
      c.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
    end
