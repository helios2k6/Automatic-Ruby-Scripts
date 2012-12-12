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
require './AudioEncoders'
require './Commands'
require './InputModule'
require './Loggers'
require './MediaObjects'
require './MediaTaskObjects'

module UnitTests
	class ExtractAudioTrackCommandUnitTests
		def runTests
			return testChoosingBestAudioTrack && testChoosingBestAudioTrack2 && testChoosingBestAudioTrack3
		end
	
		def testChoosingBestAudioTrack
			command = Commands::ExtractAudioTrackCommand.new
			
			audioTrackNilLanguage = MediaObjects::AudioTrack.new(2, 0, Constants::TrackFormat::AAC, nil)
			audioTrackNilLanguage2 = MediaObjects::AudioTrack.new(2, 1, Constants::TrackFormat::AAC, nil)
			
			audioTracks = [audioTrackNilLanguage, audioTrackNilLanguage2]
			
			result = command.chooseBestAudioTrack(audioTracks, "Japanese")
			
			return result.trackID == audioTrackNilLanguage.trackID
		end
		
		def testChoosingBestAudioTrack2
			command = Commands::ExtractAudioTrackCommand.new
			
			audioTrackNilLanguage = MediaObjects::AudioTrack.new(2, 0, Constants::TrackFormat::AAC, nil)
			audioTrackNilLanguage2 = MediaObjects::AudioTrack.new(2, 1, Constants::TrackFormat::AAC, "Japanese")
			
			audioTracks = [audioTrackNilLanguage, audioTrackNilLanguage2]
			
			result = command.chooseBestAudioTrack(audioTracks, "Japanese")
			
			return result.trackID == audioTrackNilLanguage2.trackID
		end
		
		def testChoosingBestAudioTrack3
			command = Commands::ExtractAudioTrackCommand.new
			
			audioTrackNilLanguage = MediaObjects::AudioTrack.new(2, 0, Constants::TrackFormat::AAC, "English")
			audioTrackNilLanguage2 = MediaObjects::AudioTrack.new(2, 1, Constants::TrackFormat::AAC, "Japanese")
			audioTrackNilLanguage3 = MediaObjects::AudioTrack.new(2, 1, Constants::TrackFormat::AAC, nil)
			
			audioTracks = [audioTrackNilLanguage, audioTrackNilLanguage2, audioTrackNilLanguage3]
			
			result = command.chooseBestAudioTrack(audioTracks, "Japanese")
			
			return result.trackID == audioTrackNilLanguage2.trackID
		end
	end
end

def main
	unitTest1 = UnitTests::ExtractAudioTrackCommandUnitTests.new
	
	if !unitTest1.runTests then
		puts("Unit Test 1 Failed")
	end
	
	puts("All unit tests finished")
end

main