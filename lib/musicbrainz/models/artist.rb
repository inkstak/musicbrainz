module MusicBrainz
  class Artist < Model
    include MusicBrainz::Binding::LifeSpan
    include MusicBrainz::Binding::Score
    include MusicBrainz::Binding::Urls
    include MusicBrainz::Binding::Relationships

    property :id
    property :type
    property :name
    property :sort_name
    property :country
    property :date_begin
    property :date_end
    property :disambiguation

    coerce_key :area      , Area
    coerce_key :begin_area, Area
    coerce_key :end_area  , Area

    coerce_key :relationships, Array[Relationship]

    # def release_groups limit: nil
    #   @client.browse_release_groups(artist: id, limit: limit).map do |release|
    #     release.artist ||= self
    #     release
    #   end
    # end
  end
end