module MusicBrainz
  module Configuration
    attr_reader :config

    def configure &block
      @config = block
    end

    def reset_config
      @config = nil
    end
  end

  extend Configuration
end
