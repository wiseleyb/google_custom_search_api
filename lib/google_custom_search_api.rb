##
# Add search functionality (via Google Custom Search). Protocol reference at:
# http://www.google.com/coop/docs/cse/resultsxml.html
#

require 'httparty'
require 'addressable/uri'

module GoogleCustomSearchApi
  extend self
  
  ##
  # Search the site.
  #
  # opts 
  #   see list here for valid options http://code.google.com/apis/customsearch/v1/using_rest.html#query-params
  def search(query, opts = {})
    # Get and parse results.
    url = url(query, opts)
    # puts url
    return nil unless results = fetch(url)
    results["items"] ||= []

    if file_path =  opts[:save_json_to_file_path]
      opts[:start] ||= 1
      Dir.mkdir(file_path) unless Dir.exists?(file_path)
      fname = "google_#{query.gsub(/[^0-9A-Za-z]/, '_')}_#{opts[:start]}.json"
      file = File.join(file_path, fname)
      File.delete(file) if File.exist?(file)
      open(file,'w') do |f|; f.puts results.to_json; end    
    end

    ResponseData.new(results)
  end
  
  def search_and_return_all_results(query, opts = {})
    res = []
    opts[:start] ||= 1
    begin
      results = GoogleCustomSearchApi.search(query,opts)
      # results = ResponseData.new(read_search_data("google_poker_#{opts[:start]}"))
      yield results
      res << results
      if results.queries.keys.include?("nextPage")
        opts[:start] = results.queries.nextPage.first.startIndex
      else
        opts[:start] = nil
      end
    end while opts[:start].nil? == false
    return res
  end
  
  # def read_search_data(fname)
  #   JSON.parse(File.read("/Users/wiseleyb/dev/rubyx/icm/spec/fixtures/searches/#{fname}.json"))
  # end
  
  # Convenience wrapper for the response Hash.
  # Converts keys to Strings. Crawls through all
  # member data and converts any other Hashes it
  # finds. Provides access to values through
  # method calls, which will convert underscored
  # to camel case.
  #
  # Usage:
  # 
  #  rd = ResponseData.new("AlphaBeta" => 1, "Results" => {"Gamma" => 2, "delta" => [3, 4]})
  #  puts rd.alpha_beta
  #  => 1
  #  puts rd.alpha_beta.results.gamma
  #  => 2
  #  puts rd.alpha_beta.results.delta
  #  => [3, 4]
  #
  class ResponseData < Hash
  private
    def initialize(data={})
      data.each_pair {|k,v| self[k.to_s] = deep_parse(v) }
    end
    def deep_parse(data)
      case data
      when Hash
        self.class.new(data)
      when Array
        data.map {|v| deep_parse(v) }
      else
        data
      end
    end
    def method_missing(*args)
      name = args[0].to_s
      return self[name] if has_key? name
      camelname = name.split('_').map {|w| "#{w[0,1].upcase}#{w[1..-1]}" }.join("")
      if has_key? camelname
        self[camelname]
      else
        super *args
      end
    end
  end
  
  
  private # -------------------------------------------------------------------
  
  ##
  # Build search request URL.
  #
  # see list here for valid options http://code.google.com/apis/customsearch/v1/using_rest.html#query-params
  def url(query, opts = {})
    opts[:q] = query
    opts[:alt] ||= "json"
    uri = Addressable::URI.new
    uri.query_values = opts
    begin
      params.merge!(GOOGLE_SEARCH_PARAMS)
    rescue NameError
    end
    "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_SEARCH_CX}&#{uri.query}"
  end
  
  ##
  # Query Google, and make sure it responds.
  #
  def fetch(url)
    return HTTParty.get(url)
  end
  
end
