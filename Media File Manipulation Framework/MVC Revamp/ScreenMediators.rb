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
			screenProxy = Facade.instance.retrieve_proxy(Constants::ProxyConstants::SCREEN_PROXY)
			screenCommand = note.body[0]
			screenKey = note.body[1]
			screenMsg = note.body[2]
			
			case 
			when Constants::ScreenCommand::SCREEN_COMMAND_VECTOR.include?(screenCommand)
				screenProxy.addOrUpdateString(screenKey, screenMsg)
				
			when Constants::ScreenCommand::KILL_SCREEN
				screenProxy.removeScreen(screenKey)
				
			end
			
			screenMsg = screenProxy.resolveScreensToString
			
			@file.print(screenMsg)
		end

		def list_notification_interests
			[Constants::Notifications::UPDATE_SCREEN]
		end
	end
end