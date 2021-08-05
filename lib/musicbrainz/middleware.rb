# frozen_string_literal: true

module MusicBrainz
  class Middleware < Faraday::Middleware
    class Options < Faraday::Options.new(:app_name, :app_version, :contact)
      def valid?
        app_name && app_version && contact
      end
    end

    def initialize(app, options = nil)
      super(app)
      @options = Options.from(options)
    end

    def call(env)
      env.request_headers["Accept"]     = "application/json"
      env.request_headers["User-Agent"] = user_agent_string
      env.request_headers["Via"]        = via_string

      @app.call(env)
    end

    def user_agent_string
      raise InvalidConfiguration unless @options.valid?

      "#{@options.app_name}/#{@options.app_version} (#{@options.contact})"
    end

    def via_string
      "gem musicbrainz/#{VERSION} (#{GH_PAGE_URL})"
    end
  end
end
