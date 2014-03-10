module MusicBrainz
  class Relationships < Array

    def initialize json
      array = json['relations'].inject([]) do |array, relation|
        array << Relationship.new(relation) if relation['artist']
        array
      end if json['relations']

      super array
    end
  end

  class Relationship
    attr_accessor :id, :type, :name, :year_begin, :year_end, :attributes

    def initialize json
      self.id         = json['artist']['id']
      self.name       = json['artist']['name']
      self.type       = json['type']
      self.year_begin = json['begin']
      self.year_end   = json['end']
      self.attributes = json['attributes']
    end
  end
end