# frozen_string_literal: true

module MusicBrainz
  class Relationship < Model
    coerce_key :artist, Artist
  end
end
