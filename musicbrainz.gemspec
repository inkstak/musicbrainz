# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)
require "musicbrainz/version"

Gem::Specification.new do |s|
  s.name = "musicbrainz"
  s.version = MusicBrainz::VERSION

  s.authors = ["Savater Sebastien"]
  s.email = "github.60k5k@simplelogin.co"

  s.homepage = MusicBrainz::GH_PAGE_URL
  s.licenses = ["MIT"]
  s.summary = "Client for the [MusicBrainz](http://musicbrainz.org) web service"

  s.files = Dir["lib/**/*"] + %w[LICENSE README.md]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "activesupport"
  s.add_dependency "faraday", ">= 2.0"
  s.add_dependency "hashie", ">= 3.2.0"
end
