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