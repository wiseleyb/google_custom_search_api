$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
#require 'webmock/rspec'
require 'json'
require 'google_custom_search_api'
#require 'httparty'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/.cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
end

# This is a free key - don't be a dick and use it on your site
# it's only good for 100 searches a day and is included here to make
# it easy for others to add specs/features to this gem
GOOGLE_API_KEY = 'AIzaSyDhvoOqKns47wNae6pqEzRPRkL1Svg1SoQ'
GOOGLE_SEARCH_CX = '002432975944642411257:yjhm9na8hr0'
