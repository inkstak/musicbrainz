module MusicBrainz
  class Urls < Hash

    def initialize json
      hash = json['relations'].inject({}) do |urls, relation|
        type  = relation['type']
        url   = relation['url']

        case urls[type]
        when nil    then urls[type] = url['resource']
        when Array  then urls[type] << url['resource']
        else
          urls[type] = [urls[type]] << url['resource']
        end if type && url

        urls
      end if json['relations']

      self.update hash
    end
  end
end