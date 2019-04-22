# frozen_string_literal: true

require 'hashie'

module MusicBrainz
  class Model < Hashie::Hash
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::Coercion

    def self.property(name)
      define_method(name) { self[name.to_s] }
    end

    def initialize(json)
      json.delete('relations')

      json.each_pair do |k, v|
        self[k.to_s.tr('-', '_')] = v
      end
    end
  end
end
