require "rsolr"

module RsolrTei

  class Query
    attr_accessor :url
    attr_accessor :facet_fields
    # TODO not sure that these need to be accessible
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
        @facet_fields = facets
        @default_facet_params = @@facet_params
        @default_query_params = @@query_params
      else
        raise "Provided URL must be valid! #{url}"
      end
    end

    def get_facets(fields=@facet_fields, params=@default_facet_params)
      params["facet.field"] = fields
      raw = connect(params)
    end

    def set_default_facet_params(params)
      @default_facet_params = RsolrTei.override_params(@default_facet_params, params)
    end

    def set_default_query_params(params)
      @default_query_params = RsolrTei.override_params(@default_query_params, params)
    end

    private

    def connect(params)
      req_params = RsolrTei.override_params(@default_facet_params, params)
      res = _connect(req_params)
      # error handling or parsing of response?
    end

    def _connect(params)
      res = nil
      begin
        conn = RSolr.connect :url => @url
        res = conn.get "select", :params => params
        puts "Solr Request URL: #{res.request[:uri]}"
      rescue
        raise "Unable to contact solr, something went wrong with the query or the url"
      end
      return res
    end

  end  # end of Query class
end  # end of RsolrTei module