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

module InputModule
	class InputParser
		def self.printHelp
			puts
			puts Constants::InputConstants::PROG_HELP_HEADER
			
			Constants::InputConstants::PROG_ARG_HELP_HASH.each{ |key, value|
				puts value
			}
			
			puts
		end

		def self.processArgs(argVector)
			argCollector = Hash.new
			currentSwitch = nil
			invalidArgs = []

			for currentArg in argVector			
				if Constants::InputConstants::PROG_ARG_VECTOR.include?(currentArg) then
					currentSwitch = currentArg

					if argCollector[currentArg] == nil then
						argCollector[currentArg] = Array.new
					end
				
				elsif currentArg[0,2] == Constants::ValidInputConstants::ARGUMENT_PREFIX then
					#We know this is an invalid argument since we failed the previous if statement
					invalidArgs << currentArg
				else
					currentCollection = argCollector[currentSwitch]
					currentCollection.push(currentArg)
				end
			end
			
			return argCollector
		end
	end

	class ProgramArgs
		attr_accessor :device, :files, :avsCommands, :noMultiplex, :audioTrack, :subtitleTrack, :blacklist, :quality, :postJobs, :noSubtitles, :noAudio, :hqAudio, :ensure169, :ensureJap, :encodeAudioDirectly, :ensure720p
		def initialize(argVector)	
			argHash = InputParser.processArgs(argVector)
			
			#List based arguments
			@device = argHash[Constants::InputConstants::DEVICE_ARG]
			@files = argHash[Constants::InputConstants::FILE_ARG]
			@avsCommands = argHash[Constants::InputConstants::AVS_ADD_ARG] || []
			@blacklist = argHash[Constants::InputConstants::BLACKLIST_ARG] || []
			@postJobs = argHash[Constants::InputConstants::POST_ENCODING_ARG] || []
			
			#Flag based arguments
			@noMultiplex = argHash[Constants::InputConstants::NO_MUX_ARG] != nil #Confusing. Here's what this means: If the noMultiplex flag exists, then return true; otherwise false
			@noAudio = argHash[Constants::InputConstants::NO_AUDIO_ARG] != nil
			@noSubtitles = argHash[Constants::InputConstants::NO_SUBS_ARG] != nil
			@hqAudio = argHash[Constants::InputConstants::VERY_HIGH_QUALITY_AUDIO_ARG] != nil
			@ensure169 = argHash[Constants::InputConstants::ENSURE_16_9_ASPECT_RATIO] != nil
			@ensure720p = argHash[Constants::InputConstants::ENSURE_720_P] != nil
			@ensureJap = argHash[Constants::InputConstants::ENSURE_JAPANESE] != nil
			@encodeAudioDirectly = argHash[Constants::InputConstants::ENCODE_AUDIO_DIRECTLY_ARG] != nil
			
			#Single item arguments
			audioTrackItem = argHash[Constants::InputConstants::FORCE_AUDIO_TRACK] 
			@audioTrack = (audioTrackItem != nil && audioTrackItem[0]) || audioTrackItem
			
			subtitleTrackItem = argHash[Constants::InputConstants::FORCE_SUBTITLE_TRACK]
			@subtitleTrack = (subtitleTrackItem != nil && subtitleTrackItem[0]) || subtitleTrackItem
			
			qualityItem = argHash[Constants::InputConstants::QUALITY_ARG]
			
			@quality = (qualityItem != nil && qualityItem[0]) || Constants::ValidInputConstants::MEDIUM_QUALITY
		end
	end

	class ProgramArgsProxy < Proxy
		attr_accessor :programArgs

		def initialize(argVector)
			super(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			@programArgs = ProgramArgs.new(argVector)
		end
	end
end