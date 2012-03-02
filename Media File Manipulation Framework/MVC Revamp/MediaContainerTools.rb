require './Constants'
require './MediaObjects'

module MediaContainerTools	
	class ContainerTools
		MKV_EXTRACT_BASE_COMMAND = "\"#{Constants::ExtractionToolsConstant::MKV_EXTRACT}\" --ui-language en tracks"
		MP4_EXTRACT_BASE_COMMAND = ""
		
		INDEX_OFFSET = 1 #Due to the way that MKV indexes its tracks, we must subtract 1 from most things now. not sure why they decided to fuck everyone
		
		def self.generateExtractTrackCommand(mediaFile, trackID)
			extractedTrackFileName = nil
			if mediaFile.is_a?(mediaFile) && Constants::MediaContainers::CONTAINER_VECTOR.include?(mediaFile.mediaContainerType) then
				extractedTrackFileName = mediaFile.getBaseName + Constants::TrackFormat::EXTENSION_HASH[mediaFile.getTrack(trackID).trackFormat]
				command = ""
				case mediaFile.mediaContainerType
					when Constants::MediaContainers::MKV
						command << MKV_EXTRACT_BASE_COMMAND << " \"#{mediaFile.file}\" #{trackID - INDEX_OFFSET}:\"#{extractedTrackFileName}\""
					when Constants::MediaContainers::MP4
						command << MP4_EXTRACT_BASE_COMMAND << " -raw #{trackID} \"#{mediaFile.file}\" -out \"#{extractedTrackFileName}\""
				end
				
				return [command, extractedTrackFileName]				
			end
		end
		
		def self.generateMultiplexToMP4Command(file, outputfile)
			command = "#{Constants::ExtractionToolsConstant::MP4BOX} -add \"#{file}\" -out \"#{outputfile}\""
			
			return command
		end
	end
end