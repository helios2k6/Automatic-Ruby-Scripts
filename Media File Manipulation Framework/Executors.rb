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