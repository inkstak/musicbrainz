require 'faraday'
require 'faraday_middleware'

require 'json'

require 'musicbrainz/version'
require 'musicbrainz/configuration'
require 'musicbrainz/errors'
require 'musicbrainz/client'

require 'musicbrainz/middleware/headers'
require 'musicbrainz/middleware/interval'
require 'musicbrainz/middleware/retry'

require 'musicbrainz/models/artist'
require 'musicbrainz/models/release_group'
require 'musicbrainz/models/urls'
require 'musicbrainz/models/relationships'
