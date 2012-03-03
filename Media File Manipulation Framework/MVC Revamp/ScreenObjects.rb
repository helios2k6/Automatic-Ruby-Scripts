require 'PureMVC_Ruby'
require './Constants'
module ScreenObjects
	class ScreenProxy < Proxy
		def initialize
			super(Constants::ProxyConstants::SCREEN_PROXY)
			@screenHash = Hash.new
			@mutex = Mutex.new
		end

		def addOrUpdateString(key, str)
			@mutex.lock
			if @screenHash[key] != nil then
				screen = @screenHash[key]
				screen.string = str
			else
				screen = Screen.new(key)
				screen.string = str

				@screenHash[key] = screen
			end
			@mutex.unlock
		end

		def removeScreen(key)
			@mutex.lock
			@screenHash.delete(key)
			@mutex.unlock
		end

		def resolveScreensToString
			@mutex.lock

			stringStack = []

			@screenHash.each{|key, value|
				stringStack << value.string
			}

			i = 0
			
			string = ""
			
			stringStack.each{|e|
				string = string + e 
			}
			
			@mutex.unlock
			return string
		end
	end

	class Screen
		attr_accessor :key, :string
		
		def initialize(key)
			@key = key
		end
	end
end