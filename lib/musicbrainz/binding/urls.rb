# frozen_string_literal: true

module MusicBrainz
  module Binding
    module Urls
      def initialize(json)
        if json["relations"]
          json["urls"] = json["relations"].each_with_object({}) do |relation, hash|
            type  = relation["type"]
            url   = relation["url"]

            next unless type && url

            case hash[type]
            when nil    then hash[type] = url["resource"]
            when Array  then hash[type] << url["resource"]
            else
              hash[type] = Array.wrap(hash[type])
              hash[type] << url["resource"]
            end
          end
        end

        super(json)
      end
    end
  end
end
