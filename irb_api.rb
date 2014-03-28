# To run this file over irb:
#   bundle exec irb -r './irb_api.rb'
#

require 'musicbrainz'
require 'awesome_print'
require 'active_support'

puts "Examples :" +
  "\napi.artist('5b11f4ce-a62d-471e-81fc-a69a8278c7da')" +
  "\napi.artists('Foo Fighters')" +
  "\napi.release_groups artist: '5b11f4ce-a62d-471e-81fc-a69a8278c7da'"

MusicBrainz.configure do |c|
  c.app_name    = "MusicBrainz Test"
  c.app_version = MusicBrainz::VERSION
  c.contact     = "savater.sebastien@gmail.com"

  c.faraday do |f|
    # f.use :instrumentation
    # f.response :caching, ActiveSupport::Cache.lookup_store(:file_store, './tmp/cache')
  end
end

def api
  @api ||= MusicBrainz::Client.new
end
