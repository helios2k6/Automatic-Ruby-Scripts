require 'PureMVC_Ruby'
require './Constants'
require './ScreenObjects'

module ScreenMediators
  class ScreenMediator < Mediator
    def initialize(file = $stdout)
      super(Constants::MediatorConstants::SCREEN_MEDIATOR)
      @file = file
    end

    #We assume that the body of this notification is formatted as follows
    #[ScreenWriteType, key, message]
    def handle_notification(note)
      case note.name
      when Constants::Notifications::UPDATE_SCREEN
        screenProxy = Facade.instance.retrieve_proxy(Constants::ProxyConstants::SCREEN_PROXY)

        if note.body[0] == Constants::ScreenCommand::KILL_SCREEN then
          screenProxy.removeScreen(note.body[1])
        else
          screenProxy.addOrUpdateString(note.body[1], note.body[2])
        end
        
        screenString = Constants::ScreenCommand::COMMAND_TO_CHARACTER_HASH [note.body[1]] << screenProxy.resolveScreensToString
        
        file.print screenString
      end
    end
    
    def list_notification_interests
      [Constants::Notifications::UPDATE_SCREEN]
    end
    
  end
end