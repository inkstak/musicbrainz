# frozen_string_literal: true

module MusicBrainz
  module Binding
    module Score
      def initialize(json)
        json["score"] = json["score"].to_i if json.key?("score")

        super
      end
    end
  end
end
