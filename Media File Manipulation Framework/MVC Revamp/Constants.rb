module Constants
	class ProxyConstants
		ENCODING_JOBS_PROXY = "ENCODING_JOBS_PROXY"
		LOGGER_PROXY = "LOGGER_PROXY"
		PROGRAM_ARGS_PROXY = "PROGRAM_ARGS_PROXY"
		EXECUTOR_PROXY = "EXECUTOR_PROXY"
    SCREEN_PROXY = "SCREEN_PROXY"
    MEDIA_FILE_PROXY = "MEDIA_FILE_PROXY"
    TICKET_MASTER_PROXY = "TICKET_MASTER_PROXY"
	end
	
	class MediatorConstants
		SCREEN_MEDIATOR = "SCREEN_MEDIATOR"
	end
	
	class ExecutionConstants
    #These constants are used to tell the system WHAT was executed, not 
    #that something was executed. Use the Notifications::COMMAND_EXECUTED
    #notification if you want to say that something was executed
		EXECUTED_MP4BOX_EXTRACT = "EXECUTED_MP4BOX_EXTRACT"
    EXECUTED_MP4BOX_IMPORT = "EXECUTED_MP4BOX_IMPORT"
    
    EXECUTED_MKVEXTRACT = "EXECUTED_MKVEXTRACT"
    
    EXECUTED_X264 = "EXECUTED_X264"
    
    EXECUTED_SCP = "EXECUTED_SCP"
    
    EXECUTED_UNKNOWN = "EXECUTED_UNKNOWN"
	end
  
  class DeviceConstants
    PS3_CONSTANT = "ps3"
    IPHONE4_CONSTANT = "iphone4"

    DEVICE_VECTOR = [PS3_CONSTANT, IPHONE4_CONSTANT]
  end
end