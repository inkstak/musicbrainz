require 'musicbrainz/version'
require 'musicbrainz/configuration'

module MusicBrainz

  autoload :Client    , 'musicbrainz/client'
  autoload :Middleware, 'musicbrainz/middleware'
  autoload :Throttler , 'musicbrainz/throttler'

  autoload :Model        , 'musicbrainz/model'
  autoload :Artist       , 'musicbrainz/models/artist'
  autoload :ReleaseGroup , 'musicbrainz/models/release_group'
  autoload :Release      , 'musicbrainz/models/release'
  autoload :Recording    , 'musicbrainz/models/recording'
  autoload :Area         , 'musicbrainz/models/area'
  autoload :Relationship , 'musicbrainz/models/relationship'
  autoload :Medium       , 'musicbrainz/models/medium'

  module Binding
    autoload :Score         , 'musicbrainz/binding/score'
    autoload :LifeSpan      , 'musicbrainz/binding/life_span'
    autoload :Urls          , 'musicbrainz/binding/urls'
    autoload :Relationships , 'musicbrainz/binding/relationships'
    autoload :Tracks        , 'musicbrainz/binding/tracks'
  end
end