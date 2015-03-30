require 'rsolr_cdrh'
require 'yaml'

# The below suppresses output to the terminal from the
# tests, so if you want to debug anything comment the
# configuration out at File::NULL or redirect it to a file
# http://stackoverflow.com/questions/15430551/suppress-console-output-during-rspec-tests
RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

describe RSolrCdrh do
  describe '#version' do
    it 'returns version' do
      expect(RSolrCdrh.version).to eq '0.0.1'
    end
  end

  describe '#escape' do
    it 'fills in whitespace' do
      text = "category:\"The Ballad of Bilbo Baggins\""
      escaped = RSolrCdrh.escape(text)
      expect(escaped).to eq "category:\"The%20Ballad%20of%20Bilbo%20Baggins\""
    end
  end

  describe '#hash_to_s' do
    it 'should turn hash with string keys into symbols' do
      hash = {"a" => 1, "b" => 2, :c => "3"}
      new_hash = RSolrCdrh.hash_to_s(hash)
      expect(new_hash.length).to eq 3
      expect(new_hash[:a]).to eq 1
      expect(new_hash[:c]).to eq "3"
    end
    # TODO I do not know if this is ideal behavior
    # but it is at least expected / recognized
    it 'overwrites same named string vs symbols' do
      hash = {"a" => "old", :a => "new", "b" => "bee"}
      new_hash = RSolrCdrh.hash_to_s(hash)
      expect(new_hash.length).to eq 2
      expect(new_hash[:a]).to eq "new"
      expect(new_hash[:b]).to eq "bee"
    end
  end

  describe '#is_url?' do
    it 'returns false for bad url' do
      expect(RSolrCdrh.is_url?("nota.url")).to be_falsey
    end
  end

  describe '#override_params' do
    it 'merges two hashes, giving preference to one' do
      one = {:a => "bad", :b => "good", :c => "bad"}
      two = {:a => "good", :c => "good", :d => "good"}
      # use send to get at the private method
      new_hash = RSolrCdrh.override_params(one, two)
      expect(new_hash.length).to eq 4
      expect(new_hash[:a]).to eq "good"
      expect(new_hash[:c]).to eq "good"
    end
  end

end


describe RSolrCdrh::Query do
  before(:each) do
    config = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
    @bad_url = "unl.edu:8080"
    @url = config["url"]
  end
  subject { RSolrCdrh::Query.new(@url, ["title", "category"]) }

  describe '#initialize' do
    it "initializes with good url" do
      tei = RSolrCdrh::Query.new(@url)
      expect(tei.class).to eq RSolrCdrh::Query
    end

    it "throws exception with bad url" do
      begin
        RSolrCdrh::Query.new(@bad_url)
        expect(false).to be_truthy
      rescue
        expect(true).to be_truthy
      end
    end
  end

  describe '#get_facets' do
    it 'returns the facet portion of a solr request' do
      res = subject.get_facets
      expect(res.has_key?("title")).to be_truthy
      expect(res["title"].length > 0).to be_truthy
    end
    # TODO add some tests with the params and fields overridden
  end

  describe '#get_item_by_id' do
    it 'returns a single doc' do
      res = subject.get_item_by_id("transmissnewsodb18980613")
      expect(res.class).to eq Hash
    end
  end

  describe '#set_default_facet_params' do
    it 'sets default facet params for instance' do
      facet_p = subject.set_default_facet_params({:q => "category:memorabilia", :sort => "date desc"})
      expect(facet_p[:q]).to eq "category:memorabilia"
      expect(facet_p[:sort]).to eq "date desc"
      expect(facet_p[:start]).to eq 0
      expect(facet_p[:rows]).to eq 0
      expect(facet_p['facet.sort']).to eq "index"
    end
  end

  describe '#set_default_query_params' do
    it 'sets default query params for instance' do
      query_p = subject.set_default_query_params({:q => "category:memorabilia", :sort => "date desc"})
      expect(query_p[:q]).to eq "category:memorabilia"
      expect(query_p[:rows]).to eq 50
      expect(query_p[:sort]).to eq "date desc"
      expect(query_p[:fq]).to eq []
      expect(subject.default_query_params[:q]).to eq "category:memorabilia"
      expect(subject.default_query_params[:sort]).to eq "date desc"
    end
  end

  describe '#set_default_facet_fields' do
    it 'should overwrite the existing facet fields' do
      expect(subject.facet_fields).to eq ["title", "category"]
      expect(subject.set_default_facet_fields("title", "dataType")).to eq ["title", "dataType"]
    end
  end

  describe '#query' do
    it 'retrieves the second 10 text objects' do
      res = subject.query({:qfield => "category", :qtext => "texts", :page => 2, :rows => 10})
      expect(res[:docs].length).to eq 10
      expect(res[:url].class).to eq URI::HTTP
      expect(res[:num_found] > 10).to be_truthy
    end
    it 'retrieves query that has spaces in term' do
      res = subject.query({:qfield => "source", :qtext => "Omaha Daily Bee"})
      expect(res[:docs].length).to eq 29
    end
    it 'retrieves query with spaces when using q params' do
      res = subject.query({:q => "source:\"Omaha Daily Bee\""})
      expect(res[:docs].length).to eq 29
    end
    it 'retrieves all newspapers created by Ethel Evans' do
      params = {
        :qfield => "subCategory",
        :qtext => "newspapers",
        :fqfield => "creator",
        :fqtext => "Ethel Evans"
      }
      res = subject.query(params)
      expect(res[:docs].length).to eq 13
    end
    it 'can use the defaults if given no parameters' do
      res = subject.query
      expect(res[:docs].length).to eq 50
    end
    it 'can use the original q parameter rather than the qfield and qtext symbols' do
      res = subject.query(:q => "category:texts")
      expect(res[:docs].length).to eq 50
      expect(res[:url].class).to eq URI::HTTP
      expect(res[:num_found] > 50).to be_truthy
    end
  end

  describe '#connect' do
    it 'should return a response from solr' do
      res = subject.send(:connect, {})
      expect(res["responseHeader"]["status"]).to eq 0
      expect(res["response"]["docs"].class).to eq RSolr::Response::PaginatedDocSet
    end
  end

  describe '#_connect' do
    it 'should catch a bad request' do
      res = subject.send(:_connect, {:q => "fake:fake"})
      expect(res).to be_nil
    end
    it 'should return a good request' do
      res = subject.send(:_connect, {:q => "*:*"})
      expect(res["responseHeader"]["status"]).to eq 0
      expect(res["response"]["docs"].class).to eq RSolr::Response::PaginatedDocSet
    end
  end

  describe '#_process_facets' do
    it 'should turn a sad array into happy little hashes' do
      # TODO move to a fixture?
      res = {
        "facet_counts" => {
          "facet_fields" => {
            "title" => ["The Red Pony", "8", "Peter Rabbit", "2"],
            "author" => ["Bradbury", "4", "Rowling", "3"]
          }
        }
      }
      facets = subject.send(:_process_facets, res)
      expect(facets["title"].has_key?("Peter Rabbit")).to be_truthy
      expect(facets["author"]["Rowling"]).to eq "3"
    end
    it 'should respond with nil when given a bad response' do
      facets = subject.send(:_process_facets, {"response" => {"docs" => []}})
      expect(facets).to be_nil
    end
  end


  describe '#instance variables' do
    it 'has a @url variable' do
      expect(subject.url).to eq @url
    end

    it 'has a @facet_fields variable' do
      expect(subject.facet_fields.class).to eq Array
    end
  end
end