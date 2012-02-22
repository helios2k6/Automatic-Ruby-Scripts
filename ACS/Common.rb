module Common
	require 'Logger'
	
	#Common Logger
	@LOGGER = Logger.new(STDERR)
	@LOGGER.level = Logger::INFO
	@LOGGER.formatter = proc {|severity, datetime, progname, msg| "#{severity}: #{msg}\n"}
	
	def self.getLogger()
		return @LOGGER
	end
	
	#An internal class to manage arguments
	class ArgStruct
		attr_accessor :keyframes, :splits, :exclusionZones, :input, :output, :x264Settings, :compat, :checksum, :audio, :noExec, :silent, :shutdown
		
		def initialize
			@exclusionZones = []
			@compat = []
			@splits = 1
			@noExec = false
			@silent = false
			@shutdown = false
		end
		
		def addExclusionZone(a, b)
			@exclusionZones.push(a, b)
		end
		
		def addCompatibility(a)
			@compat.push(a)
		end
		
		def getMediaOutputType
			return File.extname(@output)
		end
	end
end
