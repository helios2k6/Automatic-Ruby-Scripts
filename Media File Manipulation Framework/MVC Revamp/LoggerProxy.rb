require 'PureMVC_Ruby'
require './Constants'
class LoggerProxy < Proxy
	LOGGER = Logger.new(STDERR)
	LOGGER.level = Logger::INFO
	LOGGER.formatter = proc {|severity, datetime, progname, msg| "#{severity}: #{msg}\n"}
	
	def initialize
		super(ProxyConstants::LOGGER_PROXY)
	end
end
