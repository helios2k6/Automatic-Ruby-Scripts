require 'PureMVC_Ruby'
require './Constants'
require './ScreenObject'

module ScreenMediators
  class ScreenCommand
    PRINT_SAME_LINE = "PRINT_SAME_LINE"
    PRINT_NEW_LINE = "PRINT_NEW_LINE"
    KILL_SCREEN = "KILL_SCREEN" #this automatically gives us a new-line
    
    COMMAND_TO_CHARACTER_HASH = [PRINT_SAME_LINE => '\r', PRINT_NEW_LINE => '\n', KILL_SCREEN => '\n']
  end

  class ScreenMediator < Mediator
    def initialize(file = $stdout)
      super(MediatorConstants::SCREEN_MEDIATOR)
      @file = file
    end

    #We assume that the body of this notification is formatted as follows
    #[ScreenWriteType, key, message]
    def handle_notification(note)
      case note.name
      when NotificationConstants::UPDATE_SCREEN
        screenProxy = Facade.instance.retrieve_proxy(ProxyConstants::SCREEN_PROXY)

        if note.body[0] == ScreenCommand::KILL_SCREEN then
          screenProxy.removeScreen(note.body[1])
        else
          screenProxy.addOrUpdateString(note.body[1], note.body[2])
        end
        
        screenString = ScreenCommand::COMMAND_TO_CHARACTER_HASH [note.body[1]] << screenProxy.resolveScreensToString
        
        file.print screenString
      end
    end
  end
end