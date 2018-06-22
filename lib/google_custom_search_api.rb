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
  #   see list here for valid options
  #   http://code.google.com/apis/customsearch/v1/using_rest.html#query-params
  def search(query, opts = {})
    opts[:start] ||= 1

    if (page = opts.delete(:page))
      page = page.to_i
      opts[:start] = (page - 1).abs * 10 + 1
    else
      page = (opts[:start].to_i / 10) + 1
    end
    page = 10 if page > 10

    # Get and parse results.
    url = url(query, opts)
    return nil unless results = fetch(url)

    results['items'] ||= []

    # paging
    if results.keys.include?('queries')
      data = results['queries']['request'].first
      results['pages'] = data['totalResults'].to_i / 10
      results['pages'] = 10 if results['pages'] > 10
      results['current_page'] = page.to_i

      results['next_page'] = nil
      results['previous_page'] = nil

      if results['queries'].include?('nextPage') && page < 10
        results['next_page'] = results['current_page'] + 1
      end

      if page > 1
        results['previous_page'] = page - 1
      end
    end

    ResponseData.new(results)
  end

  ##
  # Search the site for all available results (max 100)
  #
  # This isn't so useful because it's quite slow
  #
  # Returns an array of up to 10 search(query) results
  #
  # examples:
  #
  # results = search_and_return_all_results('poker')
  # results.first.items.size # == 10
  #
  # search_and_resturn_all_results('poker') do |results|
  #   results.items.size # == 10  10 times
  # end
  #
  # search_and_return_all_results(
  #   '"California cult winery known for its Rhône"') do |results|
  #   results.items.size # == 3  1 time
  # end
  #
  # opts
  #   see list here for valid options
  #   http://code.google.com/apis/customsearch/v1/using_rest.html#query-params
  def search_and_return_all_results(query, opts = {})
    res = []
    opts[:start] ||= 1
    begin
      results = GoogleCustomSearchApi.search(query, opts)
      return res unless results.keys.include?('queries')
      yield results if block_given?
      res << results
      if results["queries"] and results.queries.keys.include?("nextPage")
        opts[:start] = results.queries.nextPage.first.startIndex
      else
        opts[:start] = nil
      end
    end while opts[:start].nil? == false
    return res
  end

  # Convenience wrapper for the response Hash.
  # Converts keys to Strings. Crawls through all
  # member data and converts any other Hashes it
  # finds. Provides access to values through
  # method calls, which will convert underscored
  # to camel case.
  #
  # Usage:
  #
  #  rd = ResponseData.new("AlphaBeta" => 1,
  #                        "Results" => {
  #                          "Gamma" => 2,
  #                          "delta" => [3, 4]})
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

      camelname = name.split('_').map do |w|
        "#{w[0,1].upcase}#{w[1..-1]}"
      end.join("")

      if has_key? camelname
        self[camelname]
      else
        super *args
      end
    end
  end


  private

  ##
  # Build search request URL.
  #
  # see list here for valid options
  # http://code.google.com/apis/customsearch/v1/using_rest.html#query-params
  def url(query, opts = {})
    opts[:q] = query
    opts[:alt] ||= "json"
    uri = Addressable::URI.new
    uri.query_values = opts
    begin
      params.merge!(GOOGLE_SEARCH_PARAMS)
    rescue NameError
    end
    "https://www.googleapis.com/customsearch/v1?" \
      "key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_SEARCH_CX}&#{uri.query}"
  end

  ##
  # Query Google, and make sure it responds.
  #
  def fetch(url)
    return HTTParty.get(url)
  end
end
