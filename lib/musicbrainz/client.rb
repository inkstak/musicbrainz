# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "musicbrainz/errors"
require "active_support/inflector"

module MusicBrainz
  Faraday::Request.register_middleware musicbrainz: -> { Middleware }
  Faraday::Request.register_middleware throttler: -> { Throttler }

  class Client
    ENDPOINT = "http://musicbrainz.org/ws/2/"

    attr_reader :http

    def initialize
      @http = Faraday.new url: ENDPOINT do |f|
        raise MissingConfiguration unless MusicBrainz.config
        raise InvalidConfiguration unless MusicBrainz.config.valid?

        f.request :musicbrainz, MusicBrainz.config.options

        yield(f) if block_given?

        f.response  :json
        f.adapter   Faraday.default_adapter
      end
    end

    %w[artist release_group release recording label].each do |type|
      dashed = type.tr("_", "-")

      define_method(type) do |uid, **options|
        lookup(dashed, uid, **options) do |json|
          "MusicBrainz::#{type.classify}".constantize.new json
        end
      end

      define_method(type.pluralize) do |*args|
        search(dashed, *args) do |json|
          (json[dashed.pluralize] || json[dashed]).map do |json_item|
            "MusicBrainz::#{type.classify}".constantize.new json_item
          end
        end
      end
    end

    private

    def get(url, options = {})
      options = build_options(options)
      data    = http.get(url, options)

      # p http.build_url(url, options)

      case data.status
      when 503 then raise RequestFailed, data.body["error"]
      when 400 then raise BadRequest, data.body["error"]
      when 404 then nil
      else
        yield data.body
      end
    end

    def lookup(path, uid, includes: [], &block)
      get "#{path}/#{uid}", includes: includes, &block
    end

    def search(path, *args, &block)
      case args[0]
      when String
        options = args.last.is_a?(Hash) ? args.pop : {}
        data    = build_search_from_string(*args, **options)
      when Hash
        data = build_search_from_hash(*args)
      else
        raise ArgumentError, "#{query.inspect} is not a valid search query"
      end

      get path, data, &block
    end

    def build_options(options)
      options.merge(
        inc: Array(options.delete(:includes)).join("+"),
        fmt: "json"
      ).delete_if { |_, v| v.nil? }
    end

    def build_search_from_string(value, limit: nil, offset: nil)
      { query: "\"#{value}\"", limit: limit, offset: offset }
    end

    def build_search_from_hash(hash)
      hash      = hash.dup
      operator  = hash.delete(:operator) || "AND"
      query     = hash.delete(:q)

      if query
        hash[:query] = query
          .map { |k, v| "#{k.to_s.tr("_", "")}:\"#{v}\"" }
          .join(" #{operator} ")
      end

      hash.except(:includes, :limit, :offset).each_key do |key|
        hash[key.to_s.tr("_", "-")] = hash.delete(key)
      end

      hash
    end
  end
end
