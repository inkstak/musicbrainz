# frozen_string_literal: true

module MusicBrainz
  class Release < Model
    include MusicBrainz::Binding::Score

    property :id
    property :title
    property :country
    property :date
    property :status
    property :disambiguation

    coerce_key :media, Array[Medium]
  end
end
