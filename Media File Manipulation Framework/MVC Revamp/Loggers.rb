require 'PureMVC_Ruby'
require './Constants'

module Loggers
  class LoggerProxy < Proxy
    LOGGER = Logger.new(STDERR)
    LOGGER.level = Logger::INFO
    LOGGER.formatter = proc {|severity, datetime, progname, msg| "#{severity}: #{msg}\n"}

    def initialize
      super(Constants::ProxyConstants::LOGGER_PROXY)
    end

    def logInfo(msg)
      LOGGER.info(msg)
    end

    def logError(msg)
      LOGGER.error(msg)
    end
  end

  class LoggerMediator < Mediator
    def initialize
      super(Constants::MediatorConstants::LOGGER_MEDIATOR)
    end

    def handle_notification(note)
      loggerProxy = Facade.instance.retrieve_proxy(Constants::ProxyConstants::LOGGER_PROXY)
      case note.name
      when Constants::Notifications::LOG_INFO
        loggerProxy.logInfo(note.body)
      when Constants::Notifications::LOG_ERROR
        loggerProxy.logError(note.body)
      end
    end
  end
end