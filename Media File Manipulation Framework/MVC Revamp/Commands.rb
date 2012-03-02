require 'PureMVC_Ruby'
require 'Thread'
require './Constants'

#All Modules should probably go here
require './InputModule'
require './MediaTaskObjects'
require './TicketMaster'
require './AudioEncoders'
require './MediaContainerTools'
require './ScreenMediators'
require './Loggers'
require './MediaInfo'

module Commands

  #General Commands
  class PrintHelpCommand < SimpleCommand
    def execute(note)
      InputModule::InputParser.printHelp
    end
  end
  #Fail out commands
  class ExitCommand < SimpleCommand
    def execute(note)
      case note.name
      when Constants::Notifications::EXIT_SUCCESS
        exit(0)
      when Constants::Notifications::EXIT_FAILURE
        exit(1)
      end
    end
  end
  class FireExternalExecutionCommand < SimpleCommand
    #Exepect note.body = command
    def execute(note)
      facade = Facade.instance
      facade.send_notification(Constants::Notifications::LOG_INFO, "Executing External Command #{note.body}")
      executorProxy = facade.retrieve_proxy(Constants::ProxyConstants::EXECUTOR_PROXY)

      executorProxy.submitCommand(note.body)
    end
  end

  class HandleExternalExecutionOutputCommand < SimpleCommand
    def execute(note) #Expect note.body = [command, stdout]
      facade = Facade.instance

      note.body[1].each{|line|
        facade.send_notification(Constants::Notifications::UPDATE_SCREEN, [Constants::ScreenCommand::PRINT_NEW_LINE, note.body[0], line])
      }

      facade.send_notification(Constants::Notifications::UPDATE_SCREEN, [Constants::ScreenCommand::KILL_SCREEN, note.body[0]])

      facade.send_notification(Constants::Notifications::EXTERNAL_COMMAND_FINISHED_EXECUTING)#Doesn't do anything for now
    end
  end

  #Input Parsing State - Initialization is automatic, but we need to validate the program args
  class ValidateProgramArgsCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      facade.send_notification(Constants::Notifications::LOG_INFO, "Validating Program Arguments")
      programArgs = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY).programArgs

      if isValidFiles(programArgs.files) && isValidDevice(programArgs.device) && isValidQuality(programArgs.quality) then
        facade.send_notification(Constants::Notifications::LOG_INFO, "Arguments Validated. Moving to Discovery State")
        facade.send_notification(Constants::Notifications::RETRIEVE_MEDIA_FILES)
      else
        facade.send_notification(Constants::Notifications::LOG_ERROR, "Invalid Arguments Passed")
        facade.send_notification(Constants::Notifications::PRINT_HELP)
        facade.send_notification(Constants::Notifications::EXIT_FAILURE)
      end

    end

    def isValidFiles(files)
      if files != nil && files.is_a?(Array) && (files[0].casecmp(Constants::ValidInputConstants::ALL_FILES) == 0) then
        return true
      end

      return false
    end

    def isValidDevice(device)
      if device != nil && Constants::DeviceConstants::DEVICE_VECTOR.include?(device) then
        return true
      end
      return false
    end

    def isValidQuality(quality)
      if quality == nil || Constants::ValidInputConstants::QUALITY_VECTOR.include?(quality) then
        return true
      end

      return false
    end
  end

  #Discovery state commands
  class RetrieveAllMediaFilesCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      mediaFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
      files = mediaFileProxy.programArgs.files
      blacklist = mediaFileProxy.programArgs.blacklist

      #Quick check
      if blacklist == nil then
        blacklist = []
      end

      facade.send_notification(Constants::Notifications::LOG_INFO, "Gathering Media Files")

      if files[0].casecmp(Constants::ValidInputConstants::ALL_FILES) == 0 then
        facade.send_notification(Constants::Notifications::LOG_INFO, "Processing All Media Files in Directory")
        cd = Dir.new('.')

        cd.each{|e|
          processFile(e, blacklist)
        }
      else
        files.each{|e|
          processFile(e, blacklist)
        }
      end

      facade.send_notification(Constants::Notifications::GENERATE_ENCODING_JOBS)
    end

    def processFile(file, blacklist)
      if MediaInfo::MediaInfoTools.isAMediaFile(file) && !blacklist.include?(file) then
        Facade.instance.send_notification(Constants::Notifications::LOG_INFO, "Adding File #{file}")
        mediaFile = MediaInfo::MediaInfoTools.getMediaInfo(file)

        mediaFileProxy = Facade.instance.retrieve_proxy(Constants::ProxyConstants::MEDIA_FILE_PROXY)

        mediaFileProxy.addMediaFile(mediaFile)
      end
    end
  end

  #Generate Encoding Jobs
  class GenerateEncodingJobsCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJobsProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      mediaFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::MEDIA_FILE_PROXY)
      programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)

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
      encodingOptions << Constants::EncodingConstants::ANIME_TUNE_ARGS

      #Always have diagnostics on
      encodingOptions << Constants::EncodingConstants::DIAGNOSTIC_ARGS

      #Always have optional optimizations
      encodingOptions << Constants::EncodingConstants::OPTIONAL_ENHANCEMENTS

      facade.send_notification(Constants::Notifications::LOG_INFO, "Generating Encoding Jobs")
      
      #Generate command array
      case quality
      when Constants::ValidInputConstants::LOW_QUALITY

        facade.send_notification(Constants::Notifications::LOG_INFO, "Using Low Quality Settings")
        encodingOptions << Constants::EncodingConstants::QUALITY_LOW

      when Constants::ValidInputConstants::MEDIUM_QUALITY

        facade.send_notification(Constants::Notifications::LOG_INFO, "Using Medium Quality Settings")
        encodingOptions << Constants::EncodingConstants::QUALITY_MEDIUM

      when Constants::ValidInputConstants::HIGH_QUALITY

        facade.send_notification(Constants::Notifications::LOG_INFO, "Using High Quality Settings")
        encodingOptions << Constants::EncodingConstants::QUALITY_HIGH

      when Constants::ValidInputConstants::EXTREME_QUALITY

        facade.send_notification(Constants::Notifications::LOG_INFO, "Using Extreme Quality Settings")
        encodingOptions << Constants::EncodingConstants::QUALITY_EXTREME

      end

      case device
      when Constants::DeviceConstants::PS3_CONSTANT
        facade.send_notification(Constants::Notifications::LOG_INFO, "Encoding for PS3")
        encodingOptions << Constants::EncodingConstants::PS3_COMPAT_ARGS
      when Constants::DeviceConstants::IPHONE4_CONSTANT
        facade.send_notification(Constants::Notifications::LOG_INFO, "Encoding for iPhone 4")
        encodingOptions << Constants::EncodingConstants::IPHONE4_COMPAT_ARGS
      end

      mediaFileProxy.mediaFiles.each{|e|
        facade.send_notification(Constants::Notifications::LOG_INFO, "Creating Encoding Job for #{e}")
        avsFile = MediaTaskObjects::AVSFile.new(e.file, avsCommands)
        encodingJob = MediaTaskObjects::EncodingJob.new(e, avsFile, generateDefaultOutputName(e.file), noMux, encodingOptions)

        encodingJob.audioTrack = audioTrack
        encodingJob.subtitleTrack = subtitleTrack

        encodingJobsProxy.addEncodingJob(encodingJob)
      }

      facade.send_notification(Constants::Notifications::EXECUTE_ALL_ENCODING_JOBS)
      
    end

    def generateDefaultOutputName(file)
      return file << "_ADE.mp4"
    end
  end

  #Encoding Cycle Super-State
  class ExecuteAllEncodingJobsCommand < SimpleCommand
    def execute(note)

      facade = Facade.instance
      encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      ticketMasterProxy = facade.retrieve_proxy(Constants::ProxyConstants::TICKET_MASTER_PROXY)
      facade.send_notification(Constants::Notifications::LOG_INFO, "Executing All Encoding Jobs")
      encodingJobProxy.encodingJobs.each{|e|
        Thread.new do
          ticketMasterProxy.getTicket
          facade.send_notification(Constants::Notifications::EXTRACT_AUDIO_TRACK, e)
          facade.send_notification(Constants::Notifications::EXTRACT_SUBTITLE_TRACK, e)
          facade.send_notification(Constants::Notifications::GENERATE_AVISYNTH_FILE, e)
          facade.send_notification(Constants::Notifications::ENCODE_FILE, e)
          facade.send_notification(Constants::Notifications::MULTIPLEX_FILE, e)
          facade.send_notification(Constants::Notifications::CLEANUP_FILES, e)
          #facade.send_notification(Constants::Notifications::EXECUTE_POST_ENCODING_COMMANDS, e) #Does nothing at the moment
          ticketMasterProxy.returnTicket
        end
      }

    end
  end

  class ExtractAudioTrackCommand < SimpleCommand
    def getPostJobsForAudioTrack(track)
      postCommand = []
      case track.trackFormat
      when Constants::TrackFormat::FLAC
        postCommand << :DECODE_FLAC
        postCommand << :ENCODE_AAC
      when Constants::TrackFormat::WAV
        postCommand << :ENCODE_AAC
      when Constants::TrackFormat::Vorbis
        postCommand << :DECODE_VORBIS
        postCommand << :ENCODE_AAC
      end

      return postCommand
    end

    def execute(note)

      facade = Facade.instance
      encodingJob = note.body
      mediaFile = encodingJob.mediaFile
      encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
      audioTrack = encodingJob.audioTrack
      postCommands = []
      facade.send_notification(Constants::Notifications::LOG_INFO, "begin Extracting Audio Track for #{mediaFile}")
      if audioTrack != nil then
        #First see if there's a particular audio track the user wants us to extract
        postCommands = getPostJobsForAudioTrack(mediafile.getTrack(audioTrack))
      else
        #Otherwise, cycle through tracks to see if any of them are audio tracks
        case mediaFile.mediaContainerType
        when Constants::MediaContainers::MKV, Constants::MediaContainers::MP4
          mediaFile.tracks.each{|e|
            case e.trackFormat
            when Constants::TrackFormat::FLAC
              facade.send_notification(Constants::Notifications::LOG_INFO, "Found FLAC Audio for #{mediaFile}")
              audioTrack = e.trackID
              postCommands = getPostJobsforAudioTrack(e)
              break
            when Constants::TrackFormat::WAV
              facade.send_notification(Constants::Notifications::LOG_INFO, "Found WAV Audio for #{mediaFile}")
              audioTrack = e.trackID
              postCommands = getPostJobsforAudioTrack(e)
              break
            when Constants::TrackFormat::AAC
              facade.send_notification(Constants::Notifications::LOG_INFO, "Found AAC Audio for #{mediaFile}")
              audioTrack = e.trackID
              break
            when Constants::TrackFormat::Vorbis
              facade.send_notification(Constants::Notifications::LOG_INFO, "Found Vorbis Audio for #{mediaFile}")
              audioTrack = e.trackID
              postCommands = getPostJobsforAudioTrack(e)
            when Constants::TrackFormat::AC3
              facade.send_notification(Constants::Notifications::LOG_INFO, "Found AC3 Audio for #{mediaFile}")
              audioTrack = e.trackID
            end
          }
        end
      end

      if audioTrack != nil then #Make sure we actually got a track
        #Extract Track, whatever it is
        facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Audio Track for #{mediaFile}")
        extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(e, audioTrack)

        facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, extractionCommand[0])

        previousFile = extractionCommand[1]

        postCommand.each{|comm|
          case comm
          when :DECODE_FLAC
            postComm = AudioEncoders::FlacDecoder.generateDecodeFlacToWavCommand(previousFile)

            facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          when :DECODE_VORBIS
            postComm = AudioEncoders::OggDecoder.generateDecodeOggToWavCommand(previousFile)

            facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          when :ENCODE_AAC
            postComm = AudioEncoders::AacEncoder.generateEncodeWavToAacCommand(previousFile)
            facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

            previousFile = postComm[1]
          end
        }

        #Assign the AAC file to the EncodingJobProxy
        encodingJobProxy.addAudioTrackFile(encodingJob, previousFile)
        tempFileProxy.addTemporaryFile(encodingJob, previousFile)
        #Done
      end

    end

  end

  class ExtractSubtitleTrackCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      mediaFile = encodingJob.mediaFile
      encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
      subtitleTrack = encodingJob.subtitleTrack
      facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Extracting Subtitle Track for #{mediaFile}")
      if subtitleTrack == nil && mediafile.mediaContainerType == Constants::MediaContainers::MKV then
        #See if the user wants to extract a particular track. If they do, then
        #we don't have to cycle through the tracks

        #Also, we can't extract subtitle tracks from any other type of media format
        mediaFile.tracks.each{|e|
          case e.trackFormat
          when Constants::TrackFormat::ASS
            facade.send_notification(Constants::Notifications::LOG_INFO, "Found ASS Track for #{mediaFile}")
            subtitleTrack = e.trackID
            break
          when Constants::TrackFormat::SSA, Constants::TrackFormat::UTF_EIGHT
            facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{e.trackFormat} Track for #{mediaFile}")
            subtitleTrack = e.trackID
          end
        }
      end

      if subtitleTrack != nil then
        #Check to see if the subtitle track actually was found
        facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Subtitle Track")
        extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(e, subtitleTrack)

        facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, extractionCommand[0])

        encodingJobProxy.addSubtitleTrackFile(encodingJob, extractionCommand[1])
        tempFileProxy.addTemporaryFile(encodingJob, extractionCommand[1])
      end
    end
  end

  class GenerateAvisynthFileCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      mediaFile = encodingJob.mediaFile
      avsFile = encodingJob.avsFile
      tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)

      outputFile = mediafile.getBaseName << MediaTaskObjects::AVSFile::AVS_EXTENSION
      facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Avisynth File Generation for #{mediafile}")
      #Get subtitle track
      encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      subtitleTrack = encodingJobProxy.getSubtitleTrackFile(encodingJob)

      if subtitleTrack != nil then
        avsFile.addPreFilter(Constants::AvisynthFilterConstants::TEXTSUB_FILTER + "(\"#{subtitleTrack}\")")
        facade.send_notification(Constants::Notifications::LOG_INFO, "Adding Textsub Prefilter for #{subtitleTrack}")
      end

      avsFile.outputAvsFile(outputFile)
      facade.send_notification(Constants::Notifications::LOG_INFO, "Output Avisynth File for #{mediaFile}")
      facade.retrieve_proxy(Constants::ProxyConstants::AVISYNTH_FILE_PROXY).addAvisynthFile(encodingJob, outputFile)
      tempFileProxy.addTemporaryFile(encodingJob, outputFile)
    end
  end

  class EncodeFileCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      mediafile = encodingJob.mediaFile
      tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
      facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Encoding #{mediaFile}")
      #form command
      command = Constants::EncodingConstants::X264
      encodingJob.encodingOptions.each{|e|
        command << " " << e
      }
      avsFile = facade.retrieve_proxy(Constants::ProxyConstants::AVISYNTH_FILE_PROXY).getAvisynthFile(encodingJob)

      command << " " << Constants::EncodingConstants::OUTPUT_ARG << " \"#{encodingJob.outputfile}\""<< " \"#{avsFile}\""

      facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, command)

      #add .ffindex file
      tempFileProxy.addTemporaryFile(encodingJob, mediaFile.getBaseFileName + ".ffindex")

    end
  end

  class MultiplexFileCommand < SimpleCommand
    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      encodedFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODED_FILE_PROXY)
      encodingJobsProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
      facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Multiplexing #{encodingJob.mediaFile}")
      encodedByteFile = encodedFileProxy.getEncodedFile(encodingJob)
      audioFile = encodingJobsProxy.getAudioTrackFile(encodingJob)

      #Multiplex only if we're suppose to and if there's an audio file to multiplex. Otherwise
      #skip multiplexing if there's only a raw 264 byte stream
      if !encodingJob.noMux && encodedByteFile != nil && audioFile != nil then
        facade.send_notification(Constants::Notifications::LOG_INFO, "Executing Multiplexing Commands for #{encodingJob.mediaFile}")
        multiplexingCommands = []
        multiplexingCommands << MediaContainerTools::ContainerTools.generateMultiplexToMP4Command(encodedByteFile, encodingJob.outputFile)
        multiplexingCommands << MediaContainerTools::ContainerTools.generateMultiplexToMP4Command(audioFile, encodingJob.outputFile)

        multiplexingCommands.each{|e|
          facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, e)
        }

        tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)


      end
    end
  end

  class CleanUpEncodingJobCommand < SimpleCommand

    def execute(note)
      facade = Facade.instance
      encodingJob = note.body
      facade.send_notification(Constants::Notifications::LOG_INFO, "Cleaning Up Files For #{encodingJob.mediaFile}")
      tempFiles = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY).getTemporaryFiles(encodingJob)

      tempFiles.each{|e|
        facade.send_notification(Constants::Notifications::LOG_INFO, "Deleting File #{e}")
        File.delete("\"#{e}\"")
      }
    end

  end

end