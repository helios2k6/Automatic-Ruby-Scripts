require 'PureMVC_Ruby'
require './Constants'

module MediaObjects
  class MediaFileProxy < Proxy
    attr_accessor :mediaFiles

    def initialize
      super(ProxyConstants::MEDIA_FILE_PROXY)
      @mediaFiles = Array.new
    end

    def addMediaFile(mediaFile)
      if mediaFile.is_a? MediaFile then
        @mediafiles << mediaFile
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