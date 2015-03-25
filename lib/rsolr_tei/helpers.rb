require 'uri'

module RsolrTei

  def self.is_url?(aUrl)
    # TODO this could be a more thorough test of the url
    # but it will check the very basics at least
    result = aUrl =~ /\A#{URI::regexp(['http', 'https'])}\z/
    return !!result  # convert to boolean
  end

end