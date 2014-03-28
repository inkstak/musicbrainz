module MusicBrainz
  module Middleware
    class Retry < Faraday::Middleware

      def initialize app, tries
        @tries = tries
        super app
      end

      def call(env)
        @last_request_at  ||= env[:request][:last_request_at]
        @try              ||= 0
        @app.call(env)

      rescue RequestIntervalTooShort => e
        raise e if (@try += 1) > @tries
        sleep e.time_to_wait
        retry
      end
    end
  end
end
