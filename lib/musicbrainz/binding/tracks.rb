# frozen_string_literal: true

module MusicBrainz
  module Binding
    module Tracks
      def initialize(json)
        json['recordings'] = (json.delete('tracks') || []).map do |track|
          track['recording'].merge(
            'track_number' => track['number'],
            'position'     => track['number'].to_i
          )
        end

        super(json)
      end
    end
  end
end
