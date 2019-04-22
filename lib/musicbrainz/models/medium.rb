# frozen_string_literal: true

module MusicBrainz
  class Medium < Model
    include MusicBrainz::Binding::Tracks

    property :title
    property :format
    property :position

    coerce_key :recordings, Array[Recording]
  end
end
