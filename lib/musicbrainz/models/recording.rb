module MusicBrainz
  class Recording < Model
    include MusicBrainz::Binding::Score

    property :id
    property :title
    property :length
    property :disambiguation

    coerce_key :length, Integer
    coerce_key :video, ->(v) { !v.nil? }
  end
end
