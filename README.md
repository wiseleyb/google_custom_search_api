# Google Custom Search

This project is a Ruby lib for Google's Custom Search ENgine API (http://www.google.com/cse).  There seem to be quite a few cse libs out there that don't work so I rolled this up quickly.

Questions/comments, etc: wiseleyb@gmail.com

## Install

Add to your Gemfile:

  `gem 'google_custom_search_api'`

then

  `bundle install`

## Configure

Create the file ```config/initializers/google_cse_api.rb``` and configure ```GOOGLE_SEARCH_CX``` and ```GOOGLE_API_KEY```:

```
  GOOGLE_API_KEY = "key_here"
  GOOGLE_SEARCH_CX = "cx_here"
```

Google's API management is confusing at best. At the time of this writing you codes like so:

### GOOGLE_API_KEY

* Go to [Google Projects](https://console.developers.google.com/project)
* Create a project, open it
* An API key can be obtained from the [Google Developers Console](https://console.developers.google.com)
* From the `Library` section, click on `Custom Search API` from under `Other popular APIs` 
* Enable Custom Search for the project you've created above, by clicking enable
* In order to use the API, you need to create credentials. Do so by clicking "Go to Credentials"
* An API key can be generated while creating your credentials. This is your `GOOGLE_API_KEY`

### GOOGLE_SEARCH_CX

* Go to [Google CSE](https://cse.google.com/cse)
* Create search engine by clicking `Add` and filling in the details and clicking `Create` 
* Open the new engine from listing page, or by clicking `Modify your search engine`. Under `Basic` tab find `Details` and click `Search engine ID`
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

### Paging

Google only returns 10 results at a time and a maximum of 100 results. The easiest way to page through results if to use `:page`. Paging is 1 based (1-10). The default page is 1

```
  results = GoogleCustomerSearchApi.search("poker", page: 2)
  results.pages == 10
  results.current_page == 2
  results.next_page == 3
  results.previous_page == 1

  results = GoogleCustomerSearchApi.search("poker", page: 1)
  results.pages == 10
  results.current_page == 1
  results.next_page == 2
  results.previous_page == nil

  results = GoogleCustomerSearchApi.search("poker", page: 10)
  results.pages == 10
  results.current_page == 10
  results.next_page == nil
  results.previous_page == 9
```

You can also use `:start` - which can be any number between 1 and 99. The `:page` helpers won't be accurate with `:start`

Example: get results 13-23

```
  results = GoogleCustomerSearchApi.search('poker', start: 13)
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
### Rails example

In **Gemfile**

```
gem "google_custom_search_api"
```

In **config/initializers/google_search.rb**

```
GOOGLE_API_KEY = '...'
GOOGLE_SEARCH_CX = '...'
```

In **config/routes.rb**

```
  get '/search' => 'search#index'
```

In **app/controllers/search_controller.rb** you'd have something like this:

```
class SearchController < ApplicationController
  def index
    if params[:q]
      page = params[:page] || 1
      @results = GoogleCustomSearchApi.search(params[:q],
                                              page: page)
	end
  end
end
```

And a simple view might look like this **app/search/index.html.erb** (this is using bootstrap styling)

```
<section class='search-section'>
  <div class='text-center titles-with-yellow'>
    <h1>Search/h1>
  </div>
  <div class='container'>
    <div class='text-center search-bar'>
      <%= form_tag search_path, method: :get  do %>
        <div class="inner-addon right-addon">
          <i class="glyphicon glyphicon-search"></i>
          <%= text_field_tag :q, params[:q], class: 'form-control' %>
        </div>
      <% end %>
    </div>
  </div>

  <% if @results && !@results.items.empty? %>
    <div class='container'>
      <% @results.items.each do |item| %>
        <div class='row'>
          <h4><%= link_to item.htmlTitle.html_safe, item.link %></h4>
          <div>
            <% if item['pagemap'] &&
                  item['pagemap']['cse_thumbnail'] &&
                  img = item.pagemap.cse_thumbnail.first %>
              <div class='col-sm-2'>
                <%= image_tag(img.src, width: '200px') %>
              </div>
              <div class='col-sm-10'>
                <%= item.htmlSnippet.html_safe %>
              </div>
            <% else %>
              <%= item.htmlSnippet.html_safe %>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    <div class='container search-prev-next'>
      <div class='row text-center'>
        <% if @results.previous_page %>
          <%= link_to '<< Previous',
            search_path(q: params[:q], page: @results.previous_page),
            class: 'btn' %>
        <% end %>
        <% @results.pages.times do |i| %>
          <%= link_to i + 1,
            search_path(q: params[:q], page: i+1),
            class: 'btn btn-page' %>
        <% end %>
        <% if @results.next_page %>
          <%= link_to 'Next >>',
            search_path(q: params[:q],
                        page: @results.next_page),
            class: 'btn' %>
        <% end %>
      </div>
    </div>
  <% else %>
    <h4>No results</h4>
  <% end %>
</section>
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
