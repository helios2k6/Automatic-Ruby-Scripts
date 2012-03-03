require 'PureMVC_Ruby'
require './Constants'

module InputModule
  class InputParser
    def self.printHelp
      puts
      puts Constants::InputConstants::PROG_HELP_HEADER
      Constants::InputConstants::PROG_ARG_HELP_HASH.each{ |key, value|
        puts value
      }
      puts
    end

    def self.processArgs(argVector)
      argCollector = Hash.new
      currentSwitch = nil

      for currentArg in argVector
        if Constants::InputConstants::PROG_ARG_VECTOR.include?(currentArg) then
          currentSwitch = currentArg

          if argCollector[currentArg] == nil then
            argCollector[currentArg] = Array.new

          end
        else
          currentCollection = argCollector[currentSwitch]
          currentCollection.push(currentArg)

        end
      end

      return argCollector
    end
  end

  class ProgramArgs
    def initialize(argVector)
      @argHash = InputParser.processArgs(argVector)
    end

    #Used just in case the user ever enters in a switch without any arguements "--avs-add --no-mux..."
    def getIndexElementOrNil(key, index)
      e = @argHash[key]
      if e != nil && e.is_a?(Array) && e[index] != nil then
        return e[index]
      end

      return nil
    end
    
    def getItemOrDefault(key)
      item = @argHash[key]
      
      if item == nil then
        item = Constants::InputConstants::PROG_ARG_DEFAULTS_HASH[key]
      end
      
      return item
    end

    def device
      getIndexElementOrNil(Constants::InputConstants::DEVICE_ARG, 0)
    end

    def files
     getItemOrDefault(Constants::InputConstants::FILE_ARG)
    end

    def avsCommands
      getItemOrDefault(Constants::InputConstants::AVS_ADD_ARG)
    end

    def noMultiplex
     getItemOrDefault(Constants::InputConstants::NO_MUX_ARG)
    end

    def audioTrack
      getIndexElementOrNil(Constants::InputConstants::FORCE_AUDIO_TRACK, 0)
    end

    def subtitleTrack
      getIndexElementOrNil(Constants::InputConstants::FORCE_SUBTITLE_TRACK, 0)
    end

    def blacklist
     getItemOrDefault(Constants::InputConstants::BLACKLIST_ARG)
    end

    def quality
      e = getIndexElementOrNil(Constants::InputConstants::QUALITY_ARG, 0)
      if e == nil then
        e = getItemOrDefault(Constants::InputConstants::QUALITY_ARG)
      end
      
      return e
    end

    def postJobs
      getItemOrDefault(Constants::InputConstants::POST_ENCODING_ARG)
    end
  end

  class ProgramArgsProxy < Proxy
    attr_accessor :programArgs

    def initialize(argVector)
      super(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
      @programArgs = ProgramArgs.new(argVector)
    end
  end
end