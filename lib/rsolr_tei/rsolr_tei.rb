require "rsolr"

module RsolrTei

  class Query
    attr_accessor :url
    attr_accessor :facet_fields
    # TODO not sure that these need to be accessible
    # but I want to test them so...meh
    attr_accessor :default_query_params
    attr_accessor :default_facet_params

    @@facet_params = {
        :q => "*:*",
        :start => 0,
        :rows => 0,
        :facet => "true",
        'facet.field' => @facet_fields,
        'facet.sort' => "index"
      }
    @@query_params = {
        :q => "*:*",
        :fq => [],
        :start => 0,
        :rows => 50,
        :start => 0,
        :sort => "title asc"
      }

    def initialize(url, facets=[])
      if RsolrTei.is_url?(url)
        @url = url
        # defaults
        @facets = facets
        @facet_fields = facets
        @default_facet_params = @@facet_params
        @default_query_params = @@query_params
      else
        raise "Provided URL must be valid! #{url}"
      end
    end

    def set_default_facet_params(params)
      @default_facet_params = _override_params(@default_facet_params, params)
    end

    def set_default_query_params(params)
      @default_query_params = _override_params(@default_query_params, params)
    end

    private

    # TODO finish this thing
    def connect(params)
      # sanitize params?
      res _connect(params)
      # error handling
    end

    def _connect(params)
      res = nil
      begin
        conn = RSolr.connect :url => @url
        res = conn.get "select", :params => params
        puts "Solr Request URL: #{res.request[:uri]}"
      rescue

      end
      return res
    end

    def _override_params(existing, requested)
      # if existing, requested share a key, requested will triumph
      return existing.merge(requested)
    end

  end  # end of Query class
end  # end of RsolrTei module