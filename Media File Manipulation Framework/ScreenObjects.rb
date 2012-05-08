#This file is part of Auto Device Encoder.
#
#Auto Device Encoder is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Auto Device Encoder is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Auto Device Encoder.  If not, see <http://www.gnu.org/licenses/>.
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