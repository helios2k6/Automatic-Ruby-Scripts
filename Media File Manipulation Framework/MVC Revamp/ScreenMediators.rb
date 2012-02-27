require 'PureMVC_Ruby'
require './Constants'

module ScreenMediators	
	class ScreenMediator < Mediator
		def initialize(file = $stdout)
			super(MediatorConstants::SCREEN_MEDIATOR)
			@screen = Screen.new(file)
		end
		
		def handle_notification(note)
			case note.name
				when NotificationConstants::UPDATE_SCREEN
					case
						when note.body[2] == ScreenWriteType::PRINT_SAME_LINE
							@screen.printSameLine(note.body[0], note.body[1])
						when note.body[2] == ScreenWriteType::PRINT_NEW_LINE
							@screen.printNewLine(note.body[0], note.body[1])
					end
			end
		end
	end
	
	class ScreenWriteType
		PRINT_SAME_LINE = "PRINT_SAME_LINE"
		PRINT_NEW_LINE = "PRINT_NEW_LINE"
	end
	
	class Screen
		attr_accessor :screenHash, :file
		
		def initialize(file)
			@file = file
			@screenHash = Hash.new	
		end
		
		def printNewLine(screenNumber, string)
			@screenHash[screenNumber] = string
			string = resolveString
			
			@file.puts string
			@file.flush
		end
		
		def printSameLine(screenNumber, string) 
			@screenHash[screenNumber] = string
			string = "\r" << resolveString
			
			@file.print string
			@file.flush
		end
		
		def resolveString
			string = ""
			@screenHash.each{|key, value|
				string << value << " | "
			}
			return string
		end
	end
end