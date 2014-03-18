module MusicBrainz
  class ReleaseGroup
    attr_accessor :id, :type, :title, :release_date,
      :primary_type, :secondary_types, :disambiguation,
      :urls, :score, :artist

    def initialize client, json
      @client = client

      self.id              = json['id']
      self.title           = json['title']

      self.primary_type    = json['primary-type']
      self.secondary_types = Array(json['secondary-types'])

      self.type = json['primary-type']
      self.type = secondary_types[0] if primary_type == 'Album' && secondary_types.any?

      self.disambiguation  = json['disambiguation']
      self.release_date    = json['first-release-date']
      self.score           = json['score'].to_i if json.key? 'score'

      self.urls            = json['relations'] && Urls.new(json)

      if json['artist-credit'] && json['artist-credit'].any?
        self.artist = Artist.new(client, json['artist-credit'][0]['artist'])
      end
    end

    def inspect
      "#<#{ self.class.name } " << (instance_variables - %i(@client)).map {|var|
        '%s: %s' % [var.to_s[1..-1], instance_variable_get(var).inspect]
      }.join(', ') << '>'
    end
  end
end