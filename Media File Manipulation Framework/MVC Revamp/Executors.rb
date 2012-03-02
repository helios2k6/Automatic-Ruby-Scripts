require 'PureMVC_Ruby'
require './Constants'
require 'pty'

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
        Facade.instance.sendNotification(Constants::Notifications::EXTERNAL_COMMAND_EXECUTED, [command, executor.stdout])
      else
        Facade.instance.sendNotification(Constants::Notifications::EXTERNAL_COMMAND_NOT_EXECUTED)
      end
    end
  end

  class Executor
    attr_accessor :callable, :stdin, :stdout, :pid, :isDone

    def initialize(callable)
      @callable = callable
      @isDone = false
      @stdin = nil
      @stdout = nil
      @pid = nil
    end

    def execute
      spawnedCommand = PTY.spawn(@callable.call)
      @stdout = spawnedCommand[0]
      @stdin = spawnedCommand[1]
      @pid = spawnedCommand[2]
    end

    def isDone
      return check(@pid) != nil
    end
  end
end