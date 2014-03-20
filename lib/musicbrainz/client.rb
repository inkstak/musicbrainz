module MusicBrainz
  class Client
    ENDPOINT = 'http://musicbrainz.org/ws/2/'

    attr_reader :http

    def initialize
      @http ||= Faraday.new url: ENDPOINT do |f|
        MusicBrainz.config.faraday.call(f) if MusicBrainz.config.faraday

        f.response  :json
        f.use       MusicBrainz::Middleware::Headers
        f.use       MusicBrainz::Middleware::Retry
        f.use       MusicBrainz::Middleware::Interval
        f.adapter   Faraday.default_adapter
      end
    end

    def artist *args
      lookup 'artist', *args do |json|
        Artist.new self, json
      end
    end

    def artists *args
      search 'artist', *args do |json|
        json['artist'].map {|j| Artist.new self, j }
      end
    end

    def release_group *args
      lookup 'release-group', *args do |json|
        ReleaseGroup.new self, json
      end
    end

    def release_groups *args
      search 'release-group', *args do |json|
        json['release-groups'].map {|j| ReleaseGroup.new self, j }
      end
    end

    def browse_release_groups artist: nil, limit: 25
      browse 'release-group', artist: artist, limit: limit do |json|
        json['release-groups'].map {|j| ReleaseGroup.new self, j }
      end
    end

  private

    def get url, options={}
      options = build_options(options)
      data    = http.get(url, options) do |request|
        request.options[:last_request_at] = @last_request_at
        @last_request_at = Time.now
      end

      case data.status
      when 400 then raise InvalidRequest.new(data.body['error'])
      when 404 then nil
      else
        yield data.body
      end

    rescue Faraday::Error::ClientError
      nil
    end

    def lookup path, uid, includes: [], &block
      get "#{path}/#{uid}", includes: includes, &block
    end

    def search path, query, limit: 10, &block
      query  = { path.gsub(/[_-]/, '') => query } if query.is_a? String
      query  = query.map {|k,v| "#{k}:\"#{v}\"" }.join(' AND ')

      get path, query: query, limit: limit, &block
    end

    def browse path, data, limit: 25, &block
      get path, data.merge(limit: limit), &block
    end

    def build_options options
      options.merge(
        inc: Array(options.delete(:includes)).join('+'),
        fmt: 'json'
      ).delete_if {|k,v| v.nil? }
    end
  end
end
