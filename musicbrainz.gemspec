require File.expand_path('../lib/musicbrainz/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'musicbrainz'
  s.version       = MusicBrainz::VERSION

  s.authors       = ['Savater Sebastien']
  s.email         = 'savater.sebastien@gmail.com'

  s.homepage      = MusicBrainz::GH_PAGE_URL
  s.summary       = 'Client for the [MusicBrainz](http://musicbrainz.org) web service'
  s.license       = 'MIT'

  s.files         = %w(Gemfile LICENSE README.md musicbrainz.gemspec)
  s.files        += Dir.glob('lib/**/*')

  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'hashie', '~> 3.2.0'
  s.add_dependency 'activesupport'
end
