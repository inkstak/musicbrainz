# frozen_string_literal: true

module MusicBrainz
  class MissingConfiguration < StandardError
  end

  class InvalidConfiguration < StandardError
  end

  class BadRequest < StandardError
  end

  class RequestFailed < StandardError
  end

  class RequestIntervalTooShort < StandardError
    attr_accessor :interval, :time_to_wait

    def initialize(message, interval: nil, time_to_wait: nil)
      self.interval     = interval
      self.time_to_wait = time_to_wait

      super(message)
    end
  end
end
