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
require "rexml/document"
include REXML

require './Constants'
require './MediaObjects'

module MediaInfo
  class MediaInfoTools
    MEDIAINFO = "mediainfo.exe"

    #XML Elements
    TYPE_ELEMENT = "type"
    FORMAT_ELEMENT = "Format"
    ID_ELEMENT = "ID"

    def self.isAMediaFile(file)
      Constants::MediaContainers::EXTENSION_HASH.has_value?(File.extname(file))
    end

    def self.processElement(element, tracks)
      trackTypeS = element.attributes[TYPE_ELEMENT]
      if Constants::TrackType::TRACK_TYPE_VECTOR.include?(trackTypeS) then
        formatS = element.elements[FORMAT_ELEMENT].get_text.to_s
        trackID = element.elements[ID_ELEMENT].get_text.to_s.to_i

        if Constants::TrackFormat::TRACK_FORMAT_VECTOR.include?(formatS) then
          newTrack = MediaObjects::MediaTrack.new(trackID, trackTypeS, formatS)
          tracks << newTrack
        end
      end
    end

    def self.getMediaInfo(file)
      args = "--output=XML \"#{file}\""

      #Don't ask why we have to execute this command like this. It's the stupidest thing ever
      xmlOutput = %x("#{MEDIAINFO}" #{args})

      document = Document.new(xmlOutput)
      rootInfo = document.elements["Mediainfo/File"]

      tracks = []

      rootInfo.elements.each{|e| processElement(e, tracks)}

      mediaType = rootInfo.elements["track[@type='#{Constants::TrackType::GENERAL}']/Format"].get_text.to_s

      if Constants::MediaContainers::CONTAINER_VECTOR.include?(mediaType) then
        mediaFile = MediaObjects::MediaFile.new(file, tracks, mediaType)
        return mediaFile
      end

      return nil
    end
  end
end