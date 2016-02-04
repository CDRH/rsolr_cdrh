require "logger"

module RSolrCdrh
  @@logger = nil

  def self.logger
    # default to using Rails logger, otherwise ruby built in
    @@logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  def self.set_logger(aLogger)
    @@logger = aLogger
  end
end