require 'faraday'

module MusicBrainz
  class Throttler < Faraday::Middleware
    class Options < Faraday::Options.new(:interval, :cache_key)
      def interval
        self[:interval] ||= 1.second
      end

      def cache_key
        self[:cache_key] ||= 'mb_last_query_time'
      end
    end

    def initialize app, cache, options = nil
      super(app)
      @cache   = cache
      @options = Options.from(options)
    end

    def call env
      @time = read_last_query_time
      write_last_query_time
      time_passed = Time.now.to_f - read_last_query_time

      wait = @options.interval - time_passed
      sleep(env['throttler_wait_time'] = wait) if wait > 0

      @app.call(env)
    end

    def read_last_query_time
      @cache.read(@options.cache_key) || 0.0
    end

    def write_last_query_time
      @cache.write(@options.cache_key, Time.now.to_f)
    end
  end
end
