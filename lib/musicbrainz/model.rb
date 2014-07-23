require 'hashie'

module MusicBrainz
  class Model < Hashie::Hash
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::Coercion

    attr_accessor :client
    private :client

    def self.property name
      define_method(name) { self[name.to_s] }
    end

    def initialize json
      json.delete('relations')

      json.each_pair do |k, v|
        self[k.to_s.gsub('-', '_')] = v
      end
      self
    end

    def reload
    end
  end
end
