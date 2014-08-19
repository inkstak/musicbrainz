module MusicBrainz
  class Release < Model
    include MusicBrainz::Binding::Score

    property :id
    property :title
    property :country
    property :date
    property :status
    property :disambiguation
  end
end