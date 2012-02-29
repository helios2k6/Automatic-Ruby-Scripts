require 'PureMVC_Ruby'
require 'Thread'
require './Constants'
require './Notifications'

#All Modules should probably go here
require './InputModule'
require './MediaTaskObjects'
require './TicketMaster'
require './AudioEncoders'
require './MediaContainerTools'
require './ScreenMediators'

module Commands

  #General Commands
  class FireExternalExecutionCommand < SimpleCommand
    #Exepect note.body = command
    def execute(note)
      facade = Facade.instance
      executorProxy = facade.retrieve_proxy(ProxyConstants::EXECUTOR_PROXY)

      executorProxy.submitCommand(note.body)
    end
  end

  class HandleExternalExecutionOutputCommand < SimpleCommand
    def execute(note) #Expect note.body = [command, stdout]
      facade = Facade.instance

      note.body[1].each{|line|
        facade.send_notification(Notifications::UPDATE_SCREEN, [ScreenCommand::PRINT_NEW_LINE, note.body[0], line])
      }

      facade.send_notification(Notifications::UPDATE_SCREEN, [ScreenCommand::KILL_SCREEN, note.body[0]])

      facade.send_notification(Notifications::EXTERNAL_COMMAND_FINISHED_EXECUTING)#Doesn't do anything for now
    end
  end

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

  #Encoding Cycle Super-State
  class ExecuteAllEncodingJobsCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJobProxy = facade.retrieve_proxy(ProxyConstants::ENCODING_JOBS_PROXY)
      ticketMasterProxy = facade.retrieve_proxy(ProxyConstants::TICKET_MASTER_PROXY)

      encodingJobProxy.encodingJobs.each{|e|
        Thread.new do
          ticketMasterProxy.getTicket
          facade.send_notification(Notifications::EXTRACT_AUDIO_TRACK, e)
          facade.send_notification(Notifications::EXTRACT_SUBTITLE_TRACK, e)
          facade.send_notification(Notifications::GENERATE_AVISYNTH_FILE, e)
          facade.send_notification(Notifications::ENCODE_FILE, e)
          facade.send_notification(Notifications::MULTIPLEX_FILE, e)
          facade.send_notification(Notifications::CLEANUP_FILES, e)
          facade.send_notification(Notifications::EXECUTE_POST_ENCODING_COMMANDS, e)
          ticketMasterProxy.returnTicket
        end
      }

    end
  end

  class ExtractAudioTrackCommand < SimpleCommand
    def getPostJobsForAudioTrack(track)
      postCommand = []
      case track.trackFormat
      when TrackFormat::FLAC
        postCommand << :DECODE_FLAC
        postCommand << :ENCODE_AAC
        break
      when TrackFormat::WAV
        postCommand << :ENCODE_AAC
        break
      when TrackFormat::Vorbis
        postCommand << :DECODE_VORBIS
        postCommand << :ENCODE_AAC
      end
      
      return postCommand
    end

    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      mediaFile = encodingJob.mediaFile
      encodingJobProxy = facade.retrieve_proxy(ProxyConstants::ENCODING_JOBS_PROXY)

      audioTrack = audioTrack = encodingJob.audioTrack
      postCommands = []

      if audioTrack != nil then

      end

      #Cycle through tracks to see if any of them are audio tracks
      case mediaFile.mediaContainerType
      when MediaContainers::MKV, MediaContainers::MP4
        mediaFile.tracks.each{|e|
          case e.trackFormat
          when TrackFormat::FLAC
            audioTrack = e.trackID
            postCommand.clear
            postCommand << :DECODE_FLAC
            postCommand << :ENCODE_AAC
            break
          when TrackFormat::WAV
            audioTrack = e.trackID
            postCommand.clear
            postCommand << :ENCODE_AAC
            break
          when TrackFormat::AAC
            audioTrack = e.trackID
            break
          when TrackFormat::Vorbis
            audioTrack = e.trackID
            postCommand << :DECODE_VORBIS
            postCommand << :ENCODE_AAC
          when TrackFormat::AC3
            audioTrack = e.trackID
          end
        }
      end

      if audioTrack > -1 then #Make sure we actually got a track
        #Extract Track, whatever it is
        extractionCommand = nil
        case mediaFile.mediaContainerType
        when MediaContainers::MKV, MediaContainers::MP4
          extractionCommand = ContainerTools.generateExtractTrackCommand(e, audioTrack)
        end

        facade.send_notification(Notifications::EXECUTE_EXTERNAL_COMMAND, extractionCommand[0])

        previousFile = extractionCommand[1]

        postCommand.each{|comm|
          case comm
          when :DECODE_FLAC
            postComm = FlacDecoder.generateDecodeFlacToWavCommand(previousFile)

            facade.send_notification(Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          when :DECODE_VORBIS
            #TODO: Decode stuff
            postComm = OggDecoder.generateDecodeOggToWavCommand(previousFile)

            facade.send_notification(Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          when :ENCODE_AAC
            postComm = AacEncoder.generateEncodeWavToAacCommand(previousFile)
            facade.send_notification(Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          end
        }

        #Assign the AAC file to the EncodingJobProxy
        encodingJobProxy.addAudioTrackFile(encodingJob, previousFile)

        #Done
      end

    end

  end

  class ExtractSubtitleTrackCommand < SimpleCommand
    def execute(note)

    end
  end
end