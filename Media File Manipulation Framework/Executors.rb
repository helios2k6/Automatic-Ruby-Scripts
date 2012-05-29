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
require 'PureMVC_Ruby'
require './Constants'

module Executors
  class ExecutorProxy < Proxy
    def initialize
      super(Constants::ProxyConstants::EXECUTOR_PROXY)
      @executors = []
    end

    def submitCommand(command)
      if command != nil && command != "" then
        executor = Executor.new(command)

        @executors << executor

        executor.execute
        
        #Send Notification with stdout reference to execution
        Facade.instance.send_notification(Constants::Notifications::EXTERNAL_COMMAND_EXECUTED, [command, executor.io])
      else
        Facade.instance.send_notification(Constants::Notifications::EXTERNAL_COMMAND_NOT_EXECUTED)
      end
    end
  end

  class Executor
    attr_accessor :command, :io, :pid

    def initialize(command)
      @command = command
    end

    def execute
      @io = IO.popen(command)
    end

  end
end