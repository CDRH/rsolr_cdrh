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

    # get_facets
    #   Sends a request to solr to return facet information for given fields
    #   Params: fields (to be faceted), params (to narrow / sort facets)
    #   Returns: hash of hash ({"author" => {"Tolkien" => 12, "Asimov" => 8}})
    def get_facets(fields=@facet_fields, params=@default_facet_params)
      params["facet.field"] = fields
      raw = connect(params)
      return _process_facets(raw)
    end

    def get_item_by_id(id)
      res = connect({:q => "id:#{id}", :rows => "1"})
      docs = _get_docs_from_response(res)
      doc = docs.nil? ? nil : docs[0]
      return doc
    end

    def set_default_facet_params(params)
      @default_facet_params = RsolrTei.override_params(@default_facet_params, params)
    end

    def set_default_query_params(params)
      @default_query_params = RsolrTei.override_params(@default_query_params, params)
    end

    def set_default_facet_fields(*fields)
      # wipe existing fields, do not add to them
      @facet_fields = fields
    end

    private

    def connect(params={})
      res = _connect(params)
      # error handling or parsing of response?
    end

    def _connect(params)
      res = nil
      begin
        conn = RSolr.connect :url => @url
        res = conn.get "select", :params => params
        puts "Solr Request URL: #{res.request[:uri]}"
      rescue => err
        res = nil
        puts "Unable to contact solr, bad request!"
        puts err
      end
      return res
    end

    def _get_docs_from_response(solrRes)
      if solrRes && solrRes["response"] && solrRes["response"]["docs"]
        return solrRes["response"]["docs"]
      else
        puts "Unexpected format for solr response, unable to find documents"
        return nil
      end
    end

    # _process_facets
    #   given a solr response, grabs the facet portion and processes into nicer format
    #   params: solrRes (response from solr)
    #   returns: nil if facets not in response, otherwise hash
    def _process_facets(solrRes)
      facet_hash = {}
      if solrRes && solrRes["facet_counts"] && solrRes["facet_counts"]["facet_fields"]
        facets = solrRes["facet_counts"]["facet_fields"]
        facets.each do |facetfield, array|
          facet_hash[facetfield] = {}
          # for each faceted field, grab the even elements of the array
          # and match them up with the following odd number
          array.each_with_index do |item, index|
            if index % 2 == 0
              facet_hash[facetfield][item] = array[index+1]
            end
          end
        end
      else
        puts "Unexpected format for solr response, unable to find facet_fields."
        facet_hash = nil
      end
      return facet_hash
    end

  end  # end of Query class
end  # end of RsolrTei module