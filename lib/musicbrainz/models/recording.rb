module MusicBrainz
  class Recording < Model
    include MusicBrainz::Binding::Score

    property :id
    property :title
    property :length
    property :disambiguation

    # FIXME Need hashie 3.2.1
    # coerce_key :length, Integer

    def initialize json
      json['length'] = json['length'].to_i
      super
    end
  end
end