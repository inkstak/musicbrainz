module MusicBrainz
  class Artist
    attr_accessor :id, :type, :name, :sort_name,
      :country, :date_begin, :date_end, :disambiguation,
      :urls, :relationships, :score

    def initialize client, json
      @client = client

      self.id             = json['id']
      self.type           = json['type']
      self.name           = json['name']
      self.sort_name      = json['sort-name']
      self.country        = json['country']
      self.date_begin     = json['life-span']['begin']
      self.date_end       = json['life-span']['end']
      self.disambiguation = json['disambiguation']
      self.score          = json['score'].to_i if json.key? 'score'

      self.urls           = json['relations'] && Urls.new(json)
      self.relationships  = json['relations'] && Relationships.new(json)
    end

    def inspect
      "#<#{ self.class.name } " << (instance_variables - %i(@client)).map {|var|
        '%s: %s' % [var.to_s[1..-1], instance_variable_get(var).inspect]
      }.join(', ') << '>'
    end

    def release_groups limit: nil
      @client.browse_release_groups artist: id, limit: limit
    end
  end
end