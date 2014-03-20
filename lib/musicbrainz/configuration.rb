module MusicBrainz
  class Configuration
    attr_accessor :app_name, :app_version, :contact,
      :query_interval, :retry

    DEFAULT_QUERY_INTERVAL = 1.5
    DEFAULT_RETRY          = 0

    def initialize
      @query_interval = DEFAULT_QUERY_INTERVAL
      @retry          = DEFAULT_RETRY
    end

    def valid?
      %w(app_name app_version contact).each do |param|
        unless instance_variable_defined?(:"@#{param}")
          raise Exception.new("Application identity parameter '#{param}' missing")
        end
      end
    end

    def faraday &block
      if block_given?
        @faraday = block
      else
        @faraday
      end
    end
  end

  module Configurable
    def configure
      raise Exception.new("Configuration block missing") unless block_given?
      yield @config ||= MusicBrainz::Configuration.new
      config.valid?
    end

    def config
      raise Exception.new("Configuration missing") unless instance_variable_defined?(:@config)
      @config
    end
  end

  extend Configurable
end
