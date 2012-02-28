require "rexml/document"
include REXML
require './MediaObjects'

module MediaInfo
  class MediaInfoTools
    MEDIAINFO = "mediainfo.exe"

    #XML Elements
    TYPE_ELEMENT = "type"
    FORMAT_ELEMENT = "Format"
    ID_ELEMENT = "ID"

    def self.isAMediaFile(file)
      MediaContainers::EXTENSION_HASH.has_key?(File.extname(file))
    end

    def self.processElement(element, tracks)
      trackTypeS = element.attributes[TYPE_ELEMENT]
      if TrackType::TRACK_TYPE_VECTOR.include?(trackTypeS) then
        formatS = element.elements[FORMAT_ELEMENT].get_text.to_s
        trackID = element.elements[ID_ELEMENT].get_text.to_s.to_i

        if TrackFormat::TRACK_FORMAT_VECTOR.include?(formatS) then
          newTrack = MediaTrack.new(trackTypeS, trackID, formatS)
          tracks << newTrack
        end
      end
    end

    def self.getMediaInfo(file)
      args = "--output=XML \"#{file}\""

      #Don't ask why we have to execute this command like this. It's the stupidest thing ever
      xmlOutput = %x("#{@MEDIAINFO}" #{args})

      document = Document.new(xmlOutput)
      rootInfo = document.elements["Mediainfo/File"]

      tracks = []

      rootInfo.elements.each{|e| processElement(e, tracks)}

      mediaType = rootInfo.elements["track[@type='#{TrackType::GENERAL}']/Format"].get_text.to_s

      if MediaContainers::CONTAINER_VECTOR.include?(mediaType) then
        mediaFile = MediaFile.new(file, tracks, mediaType)
        return mediaFile
      end

      return nil
    end
  end
end