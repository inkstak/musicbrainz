# frozen_string_literal: true

module MusicBrainz
  class Config
    attr_accessor :app_name, :app_version, :contact

    def options
      {
        app_name:    app_name,
        app_version: app_version,
        contact:     contact
      }
    end

    def valid?
      app_name && app_version && contact
    end
  end

  module Configuration
    attr_reader :config

    def configure
      yield @config = Config.new
    end

    def reset_config
      @config = nil
    end
  end

  extend Configuration
end
