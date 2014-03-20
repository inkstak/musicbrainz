module MusicBrainz
  module Middleware
    class Retry < Faraday::Middleware

      def call(env)
        @last_request_at  ||= env[:request][:last_request_at]
        @try              ||= 0
        @app.call(env)

      rescue RequestIntervalTooShort => e
        raise e if (@try += 1) > config.retry
        sleep time_to_wait
        retry
      end

      def config
        MusicBrainz.config
      end

      def time_to_wait
        config.query_interval - (Time.now.to_f - @last_request_at.to_f)
      end
    end
  end
end
