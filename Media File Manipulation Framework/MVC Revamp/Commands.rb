require 'PureMVC_Ruby'
require './Constants'
require './Notifications'

#All Modules should probably go here
require './InputModule'
require './MediaTaskObjects'

module Commands

  #Input Parsing State - Initialization is automatic, but we need to validate the program args
  class ValidateProgramArgsCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      facade.send_notification(Notifications::LOG_INFO, "Validating Program Arguments")
      programArgs = facade.retrieve_proxy(ProxyConstants::PROGRAM_ARGS_PROXY).programArgs

      if isValidFiles(programArgs.files) && isValidDevice(programArgs.device) && isValidQuality(programArgs.quality) then
        facade.send_notification(Notifications::LOG_INFO, "Arguments Validated. Moving to Discovery State")
        facade.send_notification(Notifications::RETRIEVE_MEDIA_FILES)
      else
        facade.send_notification(Notifications::LOG_ERROR, "Invalid Arguments Passed")
        facade.send_notification(Notifications::EXIT_FAILURE)
      end

    end

    def isValidFiles(files)
      if files != nil && files.is_a? Array && (files[0].casecmp(ValidInputConstants::ALL_FILES) == 0) then
        return true
      end

      return false
    end

    def isValidDevice(device)
      if device != nil && DeviceConstants::DEVICE_VECTOR.includes?(device) then
        return true
      end
      return false
    end

    def isValidQuality(quality)
      if quality == nil || ValidInputConstants::QUALITY_VECTOR.include?(quality) then
        return true
      end

      return false
    end
  end

  #Discovery state commands
  class RetrieveAllMediaFilesCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      mediaFileProxy = facade.retrieve_proxy(ProxyConstants::PROGRAM_ARGS_PROXY)
      files = mediaFileProxy.programArgs.files
      blacklist = mediaFileProxy.programArgs.blacklist

      #Quick check
      if blacklist == nil then
        blacklist = []
      end

      facade.send_notification(Notifications::LOG_INFO, "Gathering Media Files")

      if files[0].casecmp(ValidInputConstants::ALL_FILES) == 0 then
        facade.send_notification(Notifications::LOG_INFO, "Processing All Media Files in Directory")
        cd = Dir.new('.')

        cd.each{|e|
          processFile(e, blacklist)
        }
      else
        files.each{|e|
          processFile(e, blacklist)
        }
      end

      facade.send_notification(Notifications::GENERATE_ENCODING_JOBS)
    end

    def processFile(file, blacklist)
      if MediaInfoTools.isAMediaFile(file) && !blacklist.include?(file) then
        Facade.instance.send_notification(Notifications::LOG_INFO, "Adding file #{file}")
        mediaFile = MediaInfoTools.getMediaInfo(file)

        mediaFileProxy = Facade.instance.retrieve_proxy(ProxyConstants::MEDIA_FILE_PROXY)

        mediaFileProxy.addMediaFile(mediaFile)
      end
    end
  end
  
  #Generate Encoding Jobs
  class GenerateEncodingJobsCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJobsProxy = facade.retrieve_proxy(ProxyConstants::ENCODING_JOBS_PROXY)
      mediaFileProxy = facade.retrieve_proxy(ProxyConstants::MEDIA_FILE_PROXY)
      programArgsProxy = facade.retrieve_proxy(ProxyConstants::PROGRAM_ARGS_PROXY)
      
      #Retrieve encoding settings; defaults are already set and guaranteed to work
      device = programArgsProxy.programArgs.device
      audioTrack = programArgsProxy.programArgs.audioTrack
      subtitleTrack = programArgsProxy.programArgs.subtitleTrack
      quality = programArgsProxy.programArgs.quality
      avsCommands = programArgsProxy.programArgs.avsCommands
      postJobs = programArgsProxy.programArgs.postJobs
      noMux = programArgsProxy.programArgs.noMultiplex
      
      encodingOptions = []
      
      #Default until we change this to accodate other forms of media
      encodingOptions << EncodingConstants::ANIME_TUNE_ARGS
      
      #Always have diagnostics on
      encodingOptions << EncodingConstants::DIAGNOSTIC_ARGS
      
      #Always have optional optimizations
      encodingOptions << EncodingConstants::OPTIONAL_ENHANCEMENTS
      
      #Generate command array
      case quality
      when ValidInputConstants::LOW_QUALITY
        encodingOptions << EncodingConstants::QUALITY_LOW
      when ValidInputConstants::MEDIUM_QUALITY
        encodingOptions << EncodingConstants::QUALITY_MEDIUM
      when ValidInputConstants::HIGH_QUALITY
        encodingOptions << EncodingConstants::QUALITY_HIGH
      when ValidInputConstants::EXTREME_QUALITY
        encodingOptions << EncodingConstants::QUALITY_EXTREME
      end
      
      case device
      when DeviceConstants::PS3_CONSTANT
        encodingOptions << EncodingConstants::PS3_COMPAT_ARGS
      when DeviceConstants::IPHONE4_CONSTANT
        encodingOptions << EncodingConstants::IPHONE4_COMPAT_ARGS
      end
      
      mediaFileProxy.mediaFiles.each{|e|
        avsFile = AVSFile.new(e.file, avsCommands)
        encodingJob = EncodingJob.new(e, avsFile, generateDefaultOutputName(e.file), noMux, encodingOptions)
        
        encodingJob.audioTrack = audioTrack
        encodingJob.subtitleTrack = subtitleTrack
        
        encodingJobsProxy.addEncodingJob(encodingJob)
      }
      
    end
    
    def generateDefaultOutputName(file)
      return file << "_ADE.mp4"
    end
  end
end