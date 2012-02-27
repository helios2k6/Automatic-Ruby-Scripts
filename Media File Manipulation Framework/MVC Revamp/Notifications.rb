require 'PureMVC_Ruby'
module Notifications
	class Notifications
		UPDATE_SCREEN = "UPDATE_SCREEN" #Used to instruct the screen to refresh with some sort of message
		EXECUTE_COMMAND = "EXECUTE_COMMAND" #Used to instruct the execution of a command
		
		COMMAND_EXECUTED = "COMMAND_EXECUTED" #Used to signal that a command has been executed
    COMMAND_FINISHED_EXECUTING = "COMMAND_FINISHED_EXECUTING" #Used to signal that a command has finished executing
    
	end
end