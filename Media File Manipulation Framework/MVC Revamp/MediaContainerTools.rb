require './Constants'
require './MediaObjects'
require './Executors'

module MediaContainerTools	
	class ContainerTools
		MKV_EXTRACT_BASE_COMMAND = "\"#{ExtractionToolsConstant::MKV_EXTRACT}\" --ui-language en tracks"
		MP4_EXTRACT_BASE_COMMAND = ""
		
		INDEX_OFFSET = 1 #Due to the way that MKV indexes its tracks, we must subtract 1 from most things now. not sure why they decided to fuck everyone
		
		def self.generateExtractTrackCommand(mediaFile, trackID)
			extractedTrackFileName = nil
			if mediaFile.is_a?(mediaFile) && MediaContainers::CONTAINER_VECTOR.include?(mediaFile.mediaContainerType) then
				extractedTrackFileName = mediaFile.getBaseName + TrackFormat::EXTENSION_HASH[mediaFile.getTrack(trackID).trackFormat]
				command = ""
				case mediaFile.mediaContainerType
					when MediaContainers::MKV
						command << MKV_EXTRACT_BASE_COMMAND << " \"#{mediaFile.file}\" #{trackID - INDEX_OFFSET}:\"#{extractedTrackFileName}\""
					when MediaContainers::MP4
						command << MP4_EXTRACT_BASE_COMMAND << " -raw #{trackID} \"#{mediaFile.file}\" -out \"#{extractedTrackFileName}\""
				end
				
				return [command, extractedTrackFileName]				
			end
		end
		
		def self.generateMultiplexToMP4Command(file, outputfile)
			command = "#{ExtractionToolsConstant::MP4BOX} -add \"#{file}\" -out \"#{outputfile}\""
			
			return command
		end
	end
end