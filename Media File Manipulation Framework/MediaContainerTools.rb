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
require './Constants'
require './MediaObjects'

module MediaContainerTools	
	class ContainerTools
		MKV_EXTRACT_BASE_COMMAND = "\"#{Constants::ExtractionToolsConstant::MKV_EXTRACT}\" --ui-language en tracks"
		MP4_EXTRACT_BASE_COMMAND = ""
		
		INDEX_OFFSET = 1 #This is retarded
		
		def self.generateExtractTrackCommand(mediaFile, trackID)
			extractedTrackFileName = nil
			if mediaFile.is_a?(MediaObjects::MediaFile) && Constants::MediaContainers::CONTAINER_VECTOR.include?(mediaFile.mediaContainerType) then
				extractedTrackFileName = mediaFile.getBaseName + Constants::TrackFormat::EXTENSION_HASH[mediaFile.getTrack(trackID).trackFormat]
				command = ""
				case mediaFile.mediaContainerType
					when Constants::MediaContainers::MKV
						command = command + MKV_EXTRACT_BASE_COMMAND + " \"#{mediaFile.file}\" #{trackID - INDEX_OFFSET}:\"#{extractedTrackFileName}\""
					when Constants::MediaContainers::MP4
						command = command + MP4_EXTRACT_BASE_COMMAND + " -raw #{trackID} \"#{mediaFile.file}\" -out \"#{extractedTrackFileName}\""
				end
				
				return [command, extractedTrackFileName]				
			end
		end
		
		def self.generateMultiplexToMP4Command(file, outputfile)
			return "#{Constants::ExtractionToolsConstant::MP4BOX} -add \"#{file}\" \"#{outputfile}\""
		end
	end
end