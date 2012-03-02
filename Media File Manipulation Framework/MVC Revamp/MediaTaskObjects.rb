require './Constants'
require './MediaObjects'
require 'PureMVC_Ruby'

module MediaTaskObjects
  attr_accessor :encodingJobs
  class EncodingJobsProxy < Proxy
    attr_accessor :encodingJobs
    
    def initialize      
      super(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      @encodingJobs = []
      @audioFileHash = Hash.new
      @subtitleFileHash = Hash.new
    end

    def addEncodingJob(encodingJob)
      @encodingJobs << encodingJob
    end

    def addAudioTrackFile(encodingJob, audioFile)
      @audioFileHash[encodingJob] = audioFile
    end

    def addSubtitleTrackFile(encodingJob, subtitleFile)
      @subtitleFileHash[encodingJob] = subtitleFile
    end
    
    def getAudioTrackFile(encodingJob)
      return @audioFileHash[encodingJob]
    end
    
    def getSubtitleTrackFile(encodingJob)
      return @subtitleFileHash[encodingJob]
    end
  end
  
  class AvisynthFileProxy < Proxy
    def initialize
      super(Constants::ProxyConstants::AVISYNTH_FILE_PROXY)
      @avisynthFileHash = Hash.new
    end
    
    def addAvisynthFile(encodingJob, avisynthFile)
      @avisynthFileHash[encodingJob] = avisynthFile
    end
    
    def getAvisynthFile(encodingJob)
      return @avisynthFileHash[encodingJob]
    end
  end

  class EncodedFileProxy < Proxy
    def initialize
      super(Constants::ProxyConstants::ENCODED_FILE_PROXY)
      @encodedFileHash = Hash.new
    end
    
    def addEncodedFile(encodingJob, encodedFile)
      @encodedFileHash[encodingJob] = encodedFile
    end
    
    def getEncodedFile(encodingJob)
      return @encodedFileHash[encodingJob]
    end
  end

  class TemporaryFilesProxy < Proxy
    def initialize 
      super(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
      @temporaryFiles = Hash.new
    end
    
    def addTemporaryFile(encodingJob, file)
      arr = @temporaryFiles[encodingJob]
      
      if arr == nil then
        arr = []
        @temporaryFiles[encodingJob] = arr
      end
      
      arr << file
    end
    
    def getTemporaryFiles(encodingJob)
      return @temporaryFiles[encodingJob].compact
    end
  end

  class EncodingJob
    attr_accessor :mediaFile, :avsFile, :outputFile, :noMux, :encodingOptions, :audioTrack, :subtitleTrack, :postEncodingJobs, :tempFiles

    def initialize(mediaFile, avsFile, outputFile, noMux, encodingOptions, postEncodingJobs=[])
      @mediaFile = mediaFile
      @avsFile = avsFile
      @outputFile = outputFile
      @noMux = noMux
      @encodingOptions = encodingOptions #This should be an array of "EncodingConstants"
      @postEncodingJobs = postEncodingJobs
      @tempFiles = []
    end

    def getEncodingOptionsAsString
      options = ""
      @encodingOptions.each{|e|
        options << "#{e} " #That space is intentional
      }

      return options
    end

    def getBaseFileName
      return File.basename(@mediaFile, File.extname(@mediaFile))
    end
  end

  class AVSFile
    attr_accessor :mediaSource, :preFilters, :filters

    STANDARD_AVS_SCRIPT = "ffindex(x)\ny=directshowsource(x)\nffvideosource(x, fpsnum=24000, fpsden=1001)\ngradfun2db()\n"
    AVS_EXTENSION = ".avs"

    def initialize(mediaSource, filters)
      @mediaSource = mediaSource
      @filters = filters
      @preFilters = [] #These filters are meant to be executed before any user-defined filters
    end

    def addPreFilter(filter)
      @preFilters << filter
    end
    
    def addPostFilter(filter)
      @filters << filter
    end
    
    def outputAvsFile(outputFileName)
      begin
        avsFile = File.open(outputFileName, 'w')

        script = "x = #{@mediaSource}\n#{STANDARD_AVS_SCRIPT}"

        @preFilters.each{|e|
          script << "#{e}\n"
        }
        
        if @filters != nil then
          @filters.each{|e|
            script << "#{e}\n"
          }
        end

        avsFile.put(script)

      rescue
        return false
      ensure
        avsFile.close
      end

      return true
    end
  end
end