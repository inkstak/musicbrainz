require 'faraday'
require 'faraday_middleware'
require 'musicbrainz/errors'

module MusicBrainz

  Faraday::Request.register_middleware musicbrainz: lambda { Middleware }

  class Client
    ENDPOINT = 'http://musicbrainz.org/ws/2/'

    attr_reader :http

    def initialize &block
      @http ||= Faraday.new url: ENDPOINT do |f|
        raise MissingConfiguration unless MusicBrainz.config
        raise InvalidConfiguration unless MusicBrainz.config.valid?
        f.request :musicbrainz, MusicBrainz.config.options

        block.call(f) if block_given?

        f.response  :json
        f.adapter   Faraday.default_adapter
      end
    end

    def artist *args
      lookup('artist', *args) do |json|
        Artist.new json
      end
    end

    def artists *args
      search 'artist', *args do |json|
        (json['artists'] || json['artist']).map {|j| Artist.new j }
      end
    end

    def release_group *args
      lookup 'release-group', *args do |json|
        ReleaseGroup.new json
      end
    end

    def release_groups *args
      search 'release-group', *args do |json|
        json['release-groups'].map {|j| ReleaseGroup.new j }
      end
    end


  private

    def get url, options={}
      options = build_options(options)

      # p http.build_url(url, options)
      data    = http.get(url, options)

      case data.status
      when 503 then raise RequestFailed, data.body['error']
      when 400 then raise BadRequest   , data.body['error']
      when 404 then nil
      else
        yield data.body
      end
    end

    def lookup path, uid, includes: [], &block
      get "#{path}/#{uid}", includes: includes, &block
    end

    def search path, query, *args, &block
      case query
      when String then data = build_search_from_string(query, *args)
      when Hash   then data = build_search_from_hash(query)
      else
        raise ArgumentError, "#{ query.inpsect } is not a valid search query"
      end

      get path, data, &block
    end

    def build_options options
      options.merge(
        inc: Array(options.delete(:includes)).join('+'),
        fmt: 'json'
      ).delete_if {|k,v| v.nil? }
    end

    def build_search_from_string value, limit: nil, offset:  nil
      { query: "\"#{ value }\"", limit: limit, offset: offset }
    end

    def build_search_from_hash hash
      hash      = hash.dup
      operator  = hash.delete(:operator) || 'AND'
      query     = hash.delete(:q)

      if query
        hash[:query] = query.map {|k,v|
          "#{k.to_s.gsub('_', '')}:\"#{v}\""
        }.join(" #{operator} ")
      end

      hash
    end
  end
end
