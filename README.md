# Google Custom Search

This project is a Ruby lib for Google's Custom Search ENgine API (http://www.google.com/cse).  There seem to be quite a few cse libs out there that don't work so I rolled this up quickly.

Questions/comments, etc: wiseleyb@gmail.com

## Install

Add to your Gemfile:

  gem "google_custom_search_api"

then

  bundle install

## Configure

You need to configure ```GOOGLE_SEARCH_CX``` and ```GOOGLE_API_KEY``` to ```config/initializers/google_cse_api.rb```:

```
  GOOGLE_API_KEY = "..."
  GOOGLE_SEARCH_CX = "..."
```

Google's API management is confusing at best. At the time of this writing you codes like so:

### GOOGLE_API_KEY

* Go to [Google Projects](https://console.developers.google.com/project)
* Create a project, open it
* Under `Explore other services` choose `Enable APIs and get credentials like keys`
* Search for `custom search` and click on it
* In the left column click on `Credentials`
* Under `API keys` grab your key. This is your `GOOGLE_API_KEY`

### GOOGLE_SEARCH_CX

* Go to [Google CSE](https://cse.google.com/cse)
* Create a search engine and click on it
* Under `Setup > Tabs > Basic` find `Details` and click `Search engine ID`
* This is your GOOGLE_SEARCH_CX
* Make sure to add a site under `Sites to search`

## Use

### Search

To perform a search:

```
  results = GoogleCustomSearchApi.search("poker")
```
Results now contains a raw version and a class'ed version of the data show in ```Sample results``` below.

This means you can do:

```
  results["items"].each do |item|
  	puts item["title"], item["link"]
  end
```

or

```
  results.items.each do |item|
    puts item.title, item.link
  end
```

See [Custom Search](http://code.google.com/apis/customsearch/v1/using_rest.html) documentation for an explanation of all fields available.

### Search and return all results

This method isn't so useful because it's pretty slow (do to fetching up to 10 pages from Google). Helpful for testing sometimes.

```
  results = search_and_return_all_results('poker')
  results.first.items.size # == 10
  
  search_and_resturn_all_results('poker') do |results|
    results.items.size # == 10  10 times
  end
  
  search_and_return_all_results(
    '"California cult winery known for its Rhône"') do |results|
    results.items.size # == 3  1 time
  end
```

### Errors

Custom Search only returns a maximum of 100 results so - if you try something like 

```
  results = GoogleCustomSearchApi.search('poker', start: 101)
```
You get error and empty items. 

```
	{
	  "error"=> {
	    "errors"=> [
	      {
	        "domain"=>"global", 
	         "reason"=>"invalid", 
	         "message"=>"Invalid Value"
	      }
	    ], 
	    "code"=>400, 
	    "message"=>"Invalid Value"
	  }, 
	  "items"=>[]
	}
```

So check for:

```
  if results.try(:error) || results.items.empty?
```

### Paging

By default CSE returns a maximum of 10 results at a time, you can't get more results without paging. BTW if you want fewer results just pass in the :num => 1-10 option when searching.

To do paging we pass in the :start option.  Example:

```
  results = GoogleCustomSearchApi.search("poker", :start => 1)
```

The maximum number of pages CSE allows is 10 - or 100 results in total.  To walk through the pages you can use :start => 1, :start => 11, etc. Or you can use the results to find the next value, like so:

```
  start = 1
  begin
    results = GoogleCustomSearchApi.search("poker",:start => start)
    if results.items && results.queries.keys.include?("nextPage")
      start = results.queries.nextPage.first.startIndex
    else
      start = nil
    end
  end while start.nil? == false
```

The basic search result information is contained in request:

```
  results.queries.request
  => [{"title"=>"Google Custom Search - poker",
  "totalResults"=>"0",
  "searchTerms"=>"poker",
  "count"=>10,
  "inputEncoding"=>"utf8",
  "outputEncoding"=>"utf8",
  "safe"=>"off",
  "cx"=>"..."}]
```

### Encoding issues

TODO - this section needs work

CSE will return non utf-8 results which can be problematic.  I might add in a config value that you can explicitly set encoding.  Until then a work around is doing stuff like:

```
  results.items.first.title.force_encoding(Encoding::UTF_8)
```

More on this here: http://code.google.com/apis/customsearch/docs/ref_encoding.html

## Contributing - Running tests

Pull requests welcome.

To run tests
```
  git clone git@github.com:wiseleyb/google_custom_search_api.git
  cd google_custom_search_api
  bundle install
  bundle exec rspec spec
```

## Credits
* Based largely on the gem https://github.com/alexreisner/google_custom_search 
* Awesome ResponseData class from https://github.com/mikedemers/rbing
* Work done while working on a project for the company http://reInteractive.net in sunny Sydney.  A great ruby shop should you need help with something.

Copyright (c) 2012 Ben Wiseley, released under the MIT license
