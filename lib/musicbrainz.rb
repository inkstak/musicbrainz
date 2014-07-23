require 'musicbrainz/version'
require 'musicbrainz/configuration'

module MusicBrainz

  autoload :Client    , 'musicbrainz/client'
  autoload :Middleware, 'musicbrainz/middleware'

  autoload :Model        , 'musicbrainz/model'
  autoload :Artist       , 'musicbrainz/models/artist'
  autoload :ReleaseGroup , 'musicbrainz/models/release_group'
  autoload :Area         , 'musicbrainz/models/area'
  autoload :Relationship , 'musicbrainz/models/relationship'

  module Binding
    autoload :Score         , 'musicbrainz/binding/score'
    autoload :LifeSpan      , 'musicbrainz/binding/life_span'
    autoload :Urls          , 'musicbrainz/binding/urls'
    autoload :Relationships , 'musicbrainz/binding/relationships'
  end
end