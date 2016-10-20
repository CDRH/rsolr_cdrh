require 'uri'

module RSolrCdrh

  def self.escape_values(params)
    options = params.clone
    options.each do |key, value|
      if value.class == String
        RSolr.solr_escape(options[key])
      end
    end
    return options
  end

  def self.get_start(page, rows)
    return (page - 1) * rows
  end

  def self.hash_to_s(params)
    # if params are already a hash, leave them alone,
    # otherwise assume they are Rails parameters and convert to hash
    params_hash = params.class == Hash ? params : params.to_unsafe_h
    options = params_hash.clone
    symbol_params = Hash[options.map do |k, v|
          [k.to_sym, v]
        end
      ]
    return symbol_params
  end

  def self.is_url?(url)
    # TODO this could be a more thorough test of the url
    # but it will check the very basics at least
    result = url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    return !!result  # convert to boolean
  end

  def self.make_url_from_params(params)
    # shallow clone params to a new object to manipulate
    new_params = params.clone
    # remove view and pages
    new_params.delete("sort")
    new_params.delete("page")
    url = new_params.map{|k,v| "#{k}=#{v.gsub(' ', '%20')}"}.join('&')
    return url
  end

  def self.override_params(existing, requested)
    existing = self.hash_to_s(existing)
    requested = self.hash_to_s(requested)
    # if existing, requested share a key, requested will triumph
    return existing.merge(requested)
  end

  def self.set_page(page)
    new_page = page.nil? || page == "" ? 1 : page
    return new_page.to_i
  end
end
