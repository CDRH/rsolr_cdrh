# RSolrCdrh

The Center for Digital Research in the Humanities uses a standard TEI (Text Encoding Initiative) Solr schema. This gem is for avoiding repeating logic when querying solr from CDRH sites.  Includes methods like "get_item_by_id", a facet response processor, and default query settings. Methods in this gem should be widely applicable for those who wish to adopt it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rsolr_cdrh', :git => 'git://github.com/CDRH/rsolr_cdrh.git'
# once it is part of rubygems it will be gem 'rsolr_cdrh'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rsolr_cdrh

## Usage

### Quick Start
Require the gem at the top of your file and create a new instance with the url to your solr core and, optionally, any fields you wish to set as default facets.
```ruby
require 'rsolr_cdrh'
url = "http://thing.unl.edu:port/path_to_core
solr = RSolrCdrh::Query.new(url, ["title", "category", "author"])
```
Run your first request to return all objects!
```ruby
res = solr.query
puts res[:docs].class
 => RSolr::Response::PaginatedDocSet
puts res[:num_found]
 => 83
```
Want to make a specific request, perhaps all of the documents from one paper?  In the below example, you can think of `qfield` and `qtext` as being the left and right sides of q => `qfield`:`qtext` in a traditional solr query.
```ruby
res = solr.query({:qfield => "source", :qtext => "Omaha Daily Bee"})
```
You got all of the Omaha Daily Bee results but you'd really like to narrow it down to just ten results.
```ruby
res = solr.query({:qfield => "source", :qtext => "Omaha Daily Bee", :rows => 10})
```
If you want to get something by a specific id you could, of course, search for `:q => "id:#{your_id}"` but who wants to do that when you can do this?
```ruby
document = solr.get_item_by_id("27183")
```

### Defaults and Customization
Let's step back for just a second and talk about some defaults.  When you initialize a new RSolrCdrh::Query object, it comes with some assumptions.  For faceting, it uses the following settings:
```ruby
# Facet Defaults
{
   :q => "*:*",
   :start => 0,
   :rows => 0,
   :facet => "true",
   'facet.field' => [],  # Fields can be set by the user when creating the object 
   'facet.sort' => "index"
}
```
General queries have a different set of defaults:
```ruby
# Query Defaults
{
   :q => "*:*",
   :fq => [],
   :start => 0,
   :rows => 50,
   :sort => "title asc"
}
```
You can override any of these for all the requests that you might be making or on a per request basis.  You will not "add" or "change" defaults, you will be completely resetting them, so take care that you add as many keys for a request as you will need!
```ruby
# Resetting defaults for all requests
solr.set_default_query_params({
  :sort => "date desc", 
  :rows => 25,
  :start => 0,
  :q => "*:*"
  })

# You can also interact directly with the instance variables, if you prefer
solr.facet_fields = ["title", "date", "category", "publisher"]

# Uses default values except those specified by user for this request
solr.query({:q => "language:Ruby", :start => 50})
# That would be the same as this request:
solr.query({:qfield => "language", :qtext => "Ruby", :start => 50})
```
### Faceting
When you first create a new instance of the Query class, you are only required to hand over the URL, but you can also set some fields for faceting!
```ruby
solr = RSolrCdrh::Query.new(url, ["title", "category", "author"])
```
If you want to reset the default facet fields, you can do one of the following things:
```ruby
solr.set_default_facet_fields("title", "dataType", "repository")
# Using the instance variable
solr.facet_fields = ["title", "dataType", "repository")
```
However, if you are pretty happy with how the default facets work and simply want to run one bizarre request for your own gratification, you can easily do that!
```ruby
# runs with default fields and default parameters (like sort, rows, etc)
solr.get_facets
# runs with custom fields
solr.get_facets(nil, ["title", "year"])
# runs with custom fields and some specific parameters
solr.get_facets({:rows => 10, :sort => "year asc"}, ["title", "year"])
# some parameters but just the default fields
solr.get_facets({:sort => "author desc"})
```

The facets return as a hash of hashes.  That is to say, something like the following:
```ruby
{
  "author" => {
    "Herriot, James" => 10,
    "Tolkien, J.R.R." => 8
  },
  "repository" => {
    "British Museum" => 1003,
    "Willa Cather Archive" => 800,
    "London Docklands Museum" => 78
  }
}
```

### General Queries for Items

This gem cuts through rsolr's search results to get right to some of the most important information
.query() returns a hash with :url, :num_found (total number found), and :docs (an array of hashes)

```ruby
# Looking at the first three results for a *:* query
res = solr.query({:rows => 3, :sort => "title asc"})
=>  {
      :num_found => "721"  # total number in solr
      :url => "http://solr.request.com?q=*:*..."  # raw solr url
      :docs =>
      [
        {
          "id" => "281",
          "title" => "All Creatures Great and Small",
          "author" => "Herriot, James",
        },
        {
          "id" => "723",
          "title" => "Foundation",
          "author" => "Asimov, Isaac"
        },
        {
          "id" => "42",
          "title" => "The Hitchhiker's Guide to the Galaxy",
          "author" => "Adams, Douglas"
        }
      ]
    }
```
If solr does not match any documents to your search, it will return an empty array of documents.
If there is an error with your request to solr, it will return `nil`.

You can refer to the [rsolr specs](https://github.com/rsolr/rsolr) for a complete list of parameters allows, as any parameters you give to `.query` will ultimately be passed to rsolr, but rsolr_cdrh offers a few sugary parameters to make things like escaping spaces easier on the user.
```ruby
# List of custom rsolr_cdrh parameters
:qfield  # the field being queried
:qtext   # the search term
# You may use :q => field:text if you wish to avoid using qfield and qtext

:fqfield # a filter query field
:fqtext  # a field query term
# You may use :fq => [field:text] if you wish to avoid using fqfield and fqtext 

:page    # uses the rows parameter to determine which solr result to start on
```

### The Convenience of Pages
If you're displaying these results in a webpage, chances are you are going to want to offer pagination to your users.  Using either the default number of rows or a number that you specify, just pass in a page (index starts from 1) and rsolr_cdrh does the work for you.
```ruby
page_1 = solr.query({:qfield => "category", :qtext => "essays"})
 => # returns results 0 - 49 (unless the default of 50 was changed before this step)
page_2 = solr.query({:qfield => "category", :qtext => "essays", :page => 2})
 => # returns results 50 - 99

# Override the rows to get a smaller set of documents
page_1 = solr.query({:rows => 10, :page => 1})
page_2 = solr.query({:rows => 10, :page => 2})

# If you prefer to "DIY":
page_2 = solr.query({:qfield => "category", :qtext => "essays", :start => 50})
```

See the wiki pages for more documentation!

## Run Tests
If you have forked this gem, then you can run the following command to kick off the tests.  Many of them will fail if you do not have the exact same solr index hooked up as the CDRH.  In the future there may be an indexing script that will be run to populate an empty core that the tests can be pointed towards, but in the meantime, my deepest apologies.
```
bundle exec rake spec
```

## Contributing

1. Fork it ( https://github.com/CDRH/rsolr_cdrh/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests for your new features
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
