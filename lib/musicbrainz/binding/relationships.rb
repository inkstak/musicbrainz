# frozen_string_literal: true

module MusicBrainz
  module Binding
    module Relationships
      def initialize(json)
        if json['relations']
          json['relationships'] = json['relations'].each_with_object([]) do |relation, array|
            array << relation if relation['artist']
          end
        end

        super(json)
      end
    end
  end
end
