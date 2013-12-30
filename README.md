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
You can get your ```GOOGLE_API_KEY``` from https://code.google.com/apis/console/b/0/?pli=1 - There are many choices - Simple API Access is probably what you want.  There are more elaborate authorization schemes available for Google services but those aren't currently implemented.

You can get your ```GOOGLE_SEARCH_CX``` from http://www.google.com/cse/  Either create a custom engine or follow ```manage your existing search engines``` and go to your cse's Control panel.  ```GOOGLE_SEARCH_CX``` == ```Search engine unique ID```

Alternatively you can supply a key to the `search` function. `api_key` and `cx_id`

    results = GoogleCustomSearchApi.search("poker", {api_key: "", cx_id: ""})


### Searching the web, not just your site, with CSE

Google CSE was set up so search specific sites.  To search the entire web simply go to http://www.google.com/cse/, find your CSE, go to it's control panel.

* in ```Basics``` under ```Search Preferences``` choose ```Search the entire web but emphasize included sites.```
* in ```Sites``` add ```www.google.com```

## Use

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

You can get all ten pages at once by doing:

```
  results = GoogleCustomSearchApi.search_and_return_all_results(query, opts) 
  results.size == 10
  results.collect {|r| r.items.size }.sum == 100 #if there were 100 results
```

search_and_return_all_results also yields results as it goes:

```
  GoogleCustomSearchApi.search_and_return_all_results(query, opts) do |results|
    results.items.size == 10
  end
```

See [Custom Search](http://code.google.com/apis/customsearch/v1/using_rest.html) documentation for an explanation of all fields available.

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
    if results.queries.keys.include?("nextPage")
      start = results.queries.nextPage.first.startIndex
    else
      start = nil
    end
  end while start.nil? == false
```

If you just want all results you can use the method ```search_and_return_all_results(query, opts = {})``` works just like the normal search but iterates through all available results and puts them in an array.

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

## TODO
* pretty light on the tests

## Sample results

See spec/fixtures/*.json for examples of data returned


Copyright (c) 2012 Ben Wiseley, released under the MIT license
