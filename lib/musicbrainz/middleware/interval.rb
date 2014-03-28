module MusicBrainz
  module Middleware
    class Interval < Faraday::Middleware

      def initialize app, interval
        @interval = interval
        super app
      end

      def call(env)
        @last_request_at = env[:request][:last_request_at]

        raise RequestIntervalTooShort.new("interval (#{ @interval }) not respected",
          interval:     @interval,
          time_to_wait: time_to_wait
        ) unless ready?

        @app.call(env)
      end

      def time_passed
        Time.now.to_f - @last_request_at.to_f
      end

      def ready?
        time_passed > @interval
      end

      def time_to_wait
        @interval - (Time.now.to_f - @last_request_at.to_f)
      end
    end
  end
end
