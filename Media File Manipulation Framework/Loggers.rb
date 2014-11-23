#This file is part of Auto Device Encoder.
#
#Auto Device Encoder is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Auto Device Encoder is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Auto Device Encoder.  If not, see <http://www.gnu.org/licenses/>.
require 'rubygems'
require 'puremvc-ruby'
require './Constants'
require 'logger'

module Loggers
  class LoggerProxy < Proxy
    LOGGER = Logger.new(STDERR)
    LOGGER.level = Logger::INFO
    LOGGER.formatter = proc {|severity, datetime, progname, msg| "\n#{severity}: #{msg}\n"}

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
    
    def list_notification_interests
      [Constants::Notifications::LOG_INFO, Constants::Notifications::LOG_ERROR]
    end
    
  end
end