# To run this file over irb:
#   bundle exec irb -r './irb_api.rb'
#

require 'musicbrainz'
require 'awesome_print'

puts "Examples :" +
  "\napi.artist('5b11f4ce-a62d-471e-81fc-a69a8278c7da')" +
  "\napi.artists('Foo Fighters')" +
  "\napi.release_groups artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da'"

MusicBrainz.configure do |c|
  c.app_name    = "MusicBrainz Test"
  c.app_version = MusicBrainz::VERSION
  c.contact     = "savater.sebastien@gmail.com"

  # c.use :instrumentation
  # f.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
end

def api
  @api ||= MusicBrainz::Client.new
  #  do |c|
  #   c.request :retry, max: 2, interval: 0.5

  # end
end
