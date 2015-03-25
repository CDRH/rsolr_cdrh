require 'rsolr_tei'
require 'yaml'

describe RsolrTei do
  describe '#version' do
    it 'returns version' do
      expect(RsolrTei.version).to eq '0.0.1'
    end
  end

  describe '#is_url?' do
    it 'returns false for bad url' do
      expect(RsolrTei.is_url?("nota.url")).to be_falsey
    end
  end

  describe '#override_params' do
    it 'merges two hashes, giving preference to one' do
      one = {:a => "bad", :b => "good", :c => "bad"}
      two = {:a => "good", :c => "good", :d => "good"}
      # use send to get at the private method
      new_hash = RsolrTei.override_params(one, two)
      expect(new_hash.length).to eq 4
      expect(new_hash[:a]).to eq "good"
      expect(new_hash[:c]).to eq "good"
    end
  end
end


describe RsolrTei::Query do
  before(:each) do
    config = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
    @bad_url = "unl.edu:8080"
    @url = config["url"]
  end
  subject { RsolrTei::Query.new(@url) }

  describe '#initialize' do
    it "initializes with good url" do
      tei = RsolrTei::Query.new(@url)
      expect(tei.class).to eq RsolrTei::Query
    end

    it "throws exception with bad url" do
      begin
        RsolrTei::Query.new(@bad_url)
        expect(false).to be_truthy
      rescue
        expect(true).to be_truthy
      end
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


  describe '#instance variables' do
    it 'has a @url variable' do
      expect(subject.url).to eq @url
    end

    it 'has a @facet_fields variable' do
      expect(subject.facet_fields).to eq []
    end
  end
end