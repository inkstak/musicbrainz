module MusicBrainz
  module Binding
    module Relationships

      def initialize json
        json['relationships'] = json['relations'].inject([]) do |array, relation|
          array << relation if relation['artist']
          array
        end if json['relations']

        super json
      end
    end
  end
end
