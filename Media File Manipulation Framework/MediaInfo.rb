require "rexml/document"
include REXML

module MediaInfo
	#Constant names	
	@MEDIAINFO = "mediainfo.exe"
	
	class MediaFile
		attr_accessor :mediaInfoXML, :fullPathFile, :tracks
		
		def initialize(mediaInfoXML, fullPathFile)
			@mediaInfoXML = mediaInfoXML
			@fullPathFile = fullPathFile
			@tracks = []
		end
		
		def getMediaType()
			generalElements = []
			@mediaInfoXML.each_element_with_attribute("type", "General"){|e| generalElements.push(e)}
			return generalElements[0].elements["Format"].get_text.value
		end
		
		def getName()
			return File.basename(@fullPathFile)
		end
		
		def getListOfTrackTypes()
			trackTypeData = []
			@mediaInfoXML.elements.each("track"){|e| trackTypeData.push(e.attributes["type"])}
			return trackTypeData
		end
		
		def addTrack(track)
			@tracks.push(track)
		end
		
		def getTrack(trackNumber)
			for t in tracks
				if t.trackNumber == trackNumber then
					return t
				end
			end
			return nil
		end
		
	end
	
	class MediaTrack
		attr_accessor :trackType, :trackNumber, :format
		
		def initialize(trackType, trackNumber, format)
			@trackType = trackType
			@format = format
			@trackNumber = trackNumber
		end
		
		def to_s
			return "Track #{trackNumber} | Type: #{trackType} | Format: #{format}"
		end
	end
	
	def self.processElement(element, mediaFile)		
		trackType = element.attributes["type"]
		if trackType.casecmp("Video") == 0 or trackType.casecmp("Audio") == 0  or trackType.casecmp("Text") == 0 then
			format = element.elements["Format"].get_text.to_s
			trackID = element.elements["ID"].get_text.to_s.to_i
			
			mediaFile.addTrack(MediaTrack.new(trackType, trackID, format))
		end
	end
	
	def self.hydrateTrackData(mediaFile)
		mediaFile.mediaInfoXML.elements.each{|e| processElement(e, mediaFile)}
	end
	
	def self.getMediaInfo(file)
		args = "--output=XML \"#{file}\""
		
		#Don't ask why we have to execute this command like this. It's the stupidest thing ever
		xmlOutput = %x("#{@MEDIAINFO}" #{args})
		
		document = Document.new(xmlOutput)
		rootInfo = document.elements["Mediainfo/File"]
		
		mediaFile = MediaFile.new(rootInfo, file)
		
		hydrateTrackData(mediaFile)
		
		return mediaFile
	end
end