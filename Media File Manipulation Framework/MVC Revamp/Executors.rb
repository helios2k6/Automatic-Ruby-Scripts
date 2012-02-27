require 'PureMVC_Ruby'
require './Constants'
require 'pty'

module Executors	
	class ExecutorProxy < Proxy
		def initialize
			super(ProxyConstants::EXECUTOR_PROXY)
			@executors = []
		end
		
		def submitCommand(command)
			executor = Executor.new(command)
			
			@executors << executor
			
			#Send Notification with stdout reference to execution
			Facade.instance.send_notification()
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