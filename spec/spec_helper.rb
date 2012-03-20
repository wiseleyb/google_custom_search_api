$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'webmock/rspec'
require 'json'
require 'google_custom_search_api'
require 'httparty'

# from https://code.google.com/apis/console/b/0/?pli=1#project:853239283164:access 
GOOGLE_API_KEY = 'abc'

# from http://www.google.com/cse/manage/all
GOOGLE_SEARCH_CX = "123"