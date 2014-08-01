# To run this file over irb:
#   bundle exec irb -r './irb_api.rb'
#

require 'musicbrainz'
require 'awesome_print'

puts "Examples :
client.artist '5b11f4ce-a62d-471e-81fc-a69a8278c7da'
client.artists 'Nirvana'
client.artists q: { artist: 'Nirvana', country: 'se' }
client.artists q: { artist: '30 seconds to mars', alias: '30 seconds to mars' }, operator: 'OR'
client.artists q: { tag: 'Punk' }, limit: 2
client.artists release: '7a7b7bb2-5abe-3088-9e3e-6bfd54035138'
"

MusicBrainz.configure do |c|
  c.app_name    = "MusicBrainz Test"
  c.app_version = MusicBrainz::VERSION
  c.contact     = "savater.sebastien@gmail.com"

  # c.use :instrumentation
  # f.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
end

def client
  @client ||= MusicBrainz::Client.new
end
