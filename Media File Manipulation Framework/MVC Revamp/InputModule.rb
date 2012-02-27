require 'PureMVC_Ruby'
require './Constants'

module InputModule
	class InputConstants
		#Program Version
		VERSION = "2012.2.1"
		PROG_HELP_HEADER = 	"Auto Device Encoder #{VERSION}\nAuthor: Andrew Johnson\n\nUsage: ruby <this script> [options]\n\nOptions:\n\n"
		
		FILE_ARG = "--files"
		FILE_ARG_HELP_STRING =	"\t#{FILE_ARG} <file 1>[ <file 2> <file 3>...]\n\t\tThe name(s) of the media files you want to encode\n\t\tAllowed to put \"all\" to specify all media files in current dir\n\n"
		
		#Special
		DEVICE_ARG = "--device"
		DEVICE_ARG_HELP_STRING =	"\t#{DEVICE_ARG} <string>\n\t\tSpecifies the device to encode for\n\t\tValid inputs: ps3, iphone4\n\n"

		AVS_ADD_ARG = "--avs-add"
		AVS_ADD_ARG_HELP_STRING =	"\t#{AVS_ADD_ARG} <string 1>[ <string 2> <string 3>...]\n\t\tAdds extra lines into the avisynth file\n\n"

		NO_MUX_ARG = "--no-mux"
		NO_MUX_ARG_HELP_STRING =	"\t#{NO_MUX_ARG}\n\t\tDon't multiplex the raw video\n\n"

		HELP_ARG = "--help"
		HELP_ARG_HELP_STRING =	"\t#{HELP_ARG}\n\t\tPrint this help screen\n\n"
								
		FORCE_AUDIO_TRACK = "--audio-track"
		FORCE_AUDIO_TRACK_HELP_STRING =	"\t#{FORCE_AUDIO_TRACK}\n\t\tUse specified track for audio\n\n"

		FORCE_SUBTITLE_TRACK = "--subtitle-track"
		FORCE_SUBTITLE_TRACK_HELP_STRING =	"\t#{FORCE_SUBTITLE_TRACK}\n\t\tUse specified track for subtitle\n\n"

		BLACKLIST_ARG = "--blacklist"
		BLACKLIST_ARG_HELP_STRING =		"\t#{BLACKLIST_ARG} <file 1>[ <file 2> <file 3>...]\n\t\tThe name(s) of the files you want to explicitly blacklist\n\t\tCan be used in conjunction with a list of files that have been whitelisted\n\t\tThe blacklist takes precedence over the whitelist\n\n"

		PROG_ARG_VECTOR = [FILE_ARG, DEVICE_ARG, AVS_ADD_ARG, NO_MUX_ARG, HELP_ARG, FORCE_AUDIO_TRACK, FORCE_SUBTITLE_TRACK, BLACKLIST_ARG]

		PROG_ARG_HELP_HASH = {
			FILE_ARG => FILE_ARG_HELP_STRING,
			BLACKLIST_ARG => BLACKLIST_ARG_HELP_STRING,
			DEVICE_ARG => DEVICE_ARG_HELP_STRING,
			AVS_ADD_ARG => AVS_ADD_ARG_HELP_STRING,
			NO_MUX_ARG => NO_MUX_ARG_HELP_STRING,
			FORCE_AUDIO_TRACK => FORCE_AUDIO_TRACK_HELP_STRING,
			FORCE_SUBTITLE_TRACK => FORCE_SUBTITLE_TRACK_HELP_STRING
		}
	end
	
	class InputParser		
		def self.printHelp
			puts InputConstants::PROG_HELP_HEADER
			InputConstants::PROG_ARG_HELP_HASH.each{ |key, value|
				puts value
			}
		end
		
		def self.processArgs(argVector)
			argCollector = Hash.new
			currentSwitch = nil
			
			for currentArg in argVector
				if InputConstants::PROG_ARG_VECTOR.include?(currentArg) then
					currentSwitch = currentArg
					if argCollector[currentArg] == nil then
						argCollector[currentArg] = Array.new
					end
				else
					currentCollection = argCollector[currentSwitch]
					currentCollection.push(currentArg)
				end
			end
			
			return argCollector
		end
	end
	
	class ProgramArgs
		def initialize(argVector)
			@argHash = InputParser.processArgs(argVector)
		end
	
		def getIndexElementOrNil(key, index)
			e = @argHash[key]
			if e != nil && e.is_a?(Array) && e[index] != nil then
				return e[index]
			end
			
			return nil
		end
	
		def device
			getIndexElementOrNil(InputConstants::DEVICE_ARG, 0)
		end
		
		def files
			@argHash[InputConstants::FILE_ARG]
		end
		
		def avsCommands
			@argHash[InputConstants::AVS_ADD_ARG]
		end
		
		def noMultiplex
			@argHash[InputConstants::NO_MUX_ARG] != nil
		end
		
		def audioTrack
			getIndexElementOrNil(InputConstants::FORCE_AUDIO_TRACK, 0)
		end
		
		def subtitleTrack
			getIndexElementOrNil(InputConstants::FORCE_SUBTITLE_TRACK, 0)
		end
		
		def blacklist
			@argHash[InputConstants::BLACKLIST_ARG]
		end
		
		def isValid
			#Requirements
			#1. A device is selected
			#2. At least one file is named
			
			return device != nil && files != nil && files.size > 0
		end
	end
	
	class ProgramArgsProxy < Proxy
		attr_accessor :programArgs
		
		def initialize(argVector)
			super(ProxyConstants::PROGRAM_ARGS_PROXY)
			@programArgs = ProgramArgs.new(argVector)
		end
	end
end