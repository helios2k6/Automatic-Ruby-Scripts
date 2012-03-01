require 'PureMVC_Ruby'
require './Constants'

module InputModule
  class InputParser
    def self.printHelp
      puts InputConstants::PROG_HELP_HEADER
      InputConstants::PROG_ARG_HELP_HASH.each{ |key, value|
        puts value
      }
    end

    def self.processArgs(argVector)
      argCollector = Hash.new
      currentSwitch = nil

      for currentArg in argVector
        if InputConstants::PROG_ARG_VECTOR.include?(currentArg) then
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
        item = InputConstants::PROG_ARGS_DEFAULTS_HASH[key]
      end
      
      return item
    end

    def device
      getIndexElementOrNil(InputConstants::DEVICE_ARG, 0)
    end

    def files
     getItemOrDefault(InputConstants::FILE_ARG)
    end

    def avsCommands
      getItemOrDefault(InputConstants::AVS_ADD_ARG)
    end

    def noMultiplex
     getItemOrDefault(InputConstants::NO_MUX_ARG)
    end

    def audioTrack
      getIndexElementOrNil(InputConstants::FORCE_AUDIO_TRACK, 0)
    end

    def subtitleTrack
      getIndexElementOrNil(InputConstants::FORCE_SUBTITLE_TRACK, 0)
    end

    def blacklist
     getItemOrDefault(InputConstants::BLACKLIST_ARG)
    end

    def quality
      getIndexElementOrNil(InputConstants::QUALITY_ARG, 0)
    end

    def postJobs
      getItemOrDefault(InputConstants::POST_ENCODING_ARG)
    end
  end

  class ProgramArgsProxy < Proxy
    attr_accessor :programArgs

    def initialize(argVector)
      super(ProxyConstants::PROGRAM_ARGS_PROXY)
      @programArgs = ProgramArgs.new(argVector)
    end
  end
end