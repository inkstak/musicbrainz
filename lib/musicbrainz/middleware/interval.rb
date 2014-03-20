module MusicBrainz
  module Middleware
    class Interval < Faraday::Middleware
      def call(env)
        @last_request_at = env[:request][:last_request_at]
        raise RequestIntervalTooShort unless ready?

        @app.call(env)
      end

      def config
        MusicBrainz.config
      end

      def time_passed
        Time.now.to_f - @last_request_at.to_f
      end

      def ready?
        time_passed > config.query_interval
      end
    end
  end
end
