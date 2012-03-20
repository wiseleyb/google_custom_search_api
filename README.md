# Google Custom Search

This project is a Ruby lib for Google's Custom Search ENgine API (http://www.google.com/cse).  There seem to be quite a few cse libs out there that don't work so I rolled this up quickly.

Questions/comments, etc: wiseleyb@gmail.com

## Install

Add to your Gemfile:

  gem "google_custom_search_api"

then

  bundle install

## Configure

You need to configure ``GOOGLE_SEARCH_CX`` and ```GOOGLE_API_KEY``` to ```config/initializers/google_cse_api.rb```:

```
  GOOGLE_API_KEY = "..."
  GOOGLE_SEARCH_CX = "..."
```

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

See [Custom Search](http://code.google.com/apis/customsearch/v1/using_rest.html) documentation for an explanation of all fields available.

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
* Work done while working on a project for the company http://reInteractive.net in sunny Sydney.  A great ruby shop should need help with something.

## TODO
* pretty light on the tests
* support paging (will be doing this week)
* add how-to for key and cx to README

## Sample results

See spec/fixtures/*.json for examples of data returned


Copyright (c) 2012 Ben Wiseley, released under the MIT license
