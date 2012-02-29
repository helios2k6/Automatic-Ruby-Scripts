require 'PureMVC_Ruby'
require './Constants'
module ScreenObjects
  class ScreenProxy < Proxy
    def initialize
      super(ProxyConstants::SCREEN_PROXY)
      @screens = Array.new
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
        @screens << screen
      end
      @mutex.unlock
    end
    
    def removeScreen(key)
      @mutex.lock
      @screenHash.delete(key)
      @screens.delete(key)
      @mutex.unlock
    end
    
    def resolveScreensToString
      @mutex.lock
      string = ""
      @screens.each{|e|
        string << e.string << " | "
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