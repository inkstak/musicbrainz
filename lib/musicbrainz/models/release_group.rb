module MusicBrainz
  class ReleaseGroup
    attr_accessor :id, :type, :title,
      :release_date, :secondary_types, :disambiguation,
      :urls, :score

    def initialize client, json
      @client = client

      self.id              = json['id']
      self.title           = json['title']
      self.type            = json['primary-type']
      self.secondary_types = json['secondary-types']
      self.disambiguation  = json['disambiguation']
      self.release_date    = json['first-release-date']
      self.score           = json['score'].to_i if json.key? 'score'

      self.urls            = json['relations'] && Urls.new(json)
    end

    def inspect
      "#<#{ self.class.name } " << (instance_variables - %i(@client)).map {|var|
        '%s: %s' % [var.to_s[1..-1], instance_variable_get(var).inspect]
      }.join(', ') << '>'
    end
  end
end