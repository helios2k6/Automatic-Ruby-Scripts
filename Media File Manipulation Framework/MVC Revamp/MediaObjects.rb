module MediaObjects
	class TrackType
		GENERAL = "General" #This is special. Do not put this in the Track Type Vector
		VIDEO = "Video"
		AUDIO = "Audio"
		TEXT = "Text"
		
		TRACK_TYPE_VECTOR = [VIDEO, AUDIO, TEXT]
	end
	
	class TrackFormat
		AVC = "AVC"
		
		AAC = "AAC"
		FLAC = "FLAC"
		AC3 = "AC-3"
		VORBIS = "Vorbis"
		
		ASS = "ASS"
		UTF_EIGHT = "UTF-8"
		
		TRACK_FORMAT_VECTOR = [AVC, AAC, FLAC, AC3, VORBIS, ASS, UTF_EIGHT]
		
		EXTENSION_HASH = [AVC => ".264", AAC => ".aac", FLAC => ".flac", AC3 => ".ac3", VORBIS => ".ogg", ASS => ".ass", UTF_EIGHT => ".srt"]
	end
	
	class MediaContainers
		MKV = "Matroska"
		MP4 = "MPEG-4"
		
		CONTAINER_VECTOR = [MKV, MP4]
		
		EXTENSION_HASH = [MKV => ".mkv", MP4 => ".mp4"]
	end
		
	class MediaFile
		attr_accessor :file, :tracks, :mediaContainerType
		
		def initialize(file, tracks, mediaContainerType)
			@file = file
			@tracks = tracks
			@mediaContainerType = mediaContainerType
		end
		
		def numTracks
			tracks.length
		end
		
		def getTrack(trackID)
			tracks.each{|e|
				if e.trackID == trackID then
					return e
				end
			}
			
			return nil
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

end