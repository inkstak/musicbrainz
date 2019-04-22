# frozen_string_literal: true

module MusicBrainz
  class ReleaseGroup < Model
    include MusicBrainz::Binding::Score
    include MusicBrainz::Binding::Urls

    property :id
    property :type
    property :title
    property :first_release_date
    property :primary_type
    property :secondary_types
    property :disambiguation

    coerce_key :secondary_types, Array
    coerce_key :artist,          Artist

    # if json['artist-credit'] && json['artist-credit'].any?
    #   self.artist = Artist.new(client, json['artist-credit'][0]['artist'])
    # end
  end
end
