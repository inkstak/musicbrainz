# frozen_string_literal: true

module MusicBrainz
  module Binding
    module LifeSpan
      def initialize(json)
        life = json.delete('life-span') || {}

        json['date_begin'] = life['begin']
        json['date_end']   = life['ended'] ? life['end'] : nil

        super(json)
      end
    end
  end
end
