# frozen_string_literal: true

# To run this file over irb:
#   bundle exec irb -r './console.rb'
#

require "musicbrainz"
require "awesome_print"

email = `git config --get user.email`.strip
raise MusicBrainz::InvalidConfiguration if email.nil? || email.length.zero?

MusicBrainz.configure do |c|
  c.app_name = "MusicBrainz Test"
  c.app_version = MusicBrainz::VERSION
  c.contact = `git config --get user.email`.strip

  # c.use :instrumentation
  # c.response :caching, ActiveSupport::Cache.lookup_store(:file_store, "./tmp/cache")
end

def client
  @client ||= MusicBrainz::Client.new
end

puts "Examples :
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
client.artists 'Nirvana'
client.artists q: { artist: 'Nirvana', country: 'se' }
client.artists q: { artist: '30 seconds to mars', alias: '30 seconds to mars' }, operator: 'OR'
client.artists q: { tag: 'Punk' }, limit: 2
client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138'
"
