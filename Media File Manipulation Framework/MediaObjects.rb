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
require 'puremvc-ruby'
require './Constants'

module MediaObjects
	class MediaFileProxy < Proxy
		attr_accessor :mediaFiles

		def initialize
			super(Constants::ProxyConstants::MEDIA_FILE_PROXY)
			@mediaFiles = Array.new
		end

		def addMediaFile(mediaFile)
				if mediaFile.is_a? MediaFile then
				@mediaFiles << mediaFile
				end
			end
		end

	class MediaFile
		attr_accessor :file, :tracks, :mediaContainerType

		def initialize(file, tracks, mediaContainerType)
			@file = file
			@tracks = tracks
			@mediaContainerType = mediaContainerType
		end

		def numTracks
			racks.length
		end

		def getTrack(trackID)
			tracks.each{|e|
				if e.trackID == trackID then
					return e
				end
			}
			return nil
		end
		
		def getVideoTracks
			response = Array.new
			tracks.each{|e|
				if e.trackType == Constants::TrackType::VIDEO then
					response << e
				end
			}
			return response
		end
		
		def getAudioTracks
			response = Array.new
			tracks.each{|e|
				if e.trackType == Constants::TrackType::AUDIO then
					response << e
				end
			}
			
			return response;
		end
		
		def getBaseName
			File.basename(file, File.extname(file))
		end
	end

	class MediaTrack
		attr_accessor :trackID, :trackType, :trackFormat

		def initialize(trackID, trackType, trackFormat)
			@trackID = trackID
			@trackType = trackType
			@trackFormat = trackFormat
		end
		
	end

	class VideoTrack < MediaTrack
		attr_accessor :width, :height, :DAR
		
		def initialize(trackID, trackFormat, width, height, dar)
			super(trackID, Constants::TrackType::VIDEO, trackFormat)
			@width = width
			@height = height
			@DAR = dar
		end
	end
	
	class AudioTrack < MediaTrack
		attr_accessor :channels, :language
		
		def initialize(channels, trackID, trackFormat, language=nil)
			super(trackID, Constants::TrackType::AUDIO, trackFormat)
			@channels = channels
			@language = language
		end
	end
	
	class SubtitleTrack < MediaTrack
		def initialize(trackID, trackFormat)
			super(trackID,  Constants::TrackType::TEXT, trackFormat)
		end
	end
end