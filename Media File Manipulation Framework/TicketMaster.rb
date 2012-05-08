require 'PureMVC_Ruby'
require './Constants'

module TicketMaster
  class TicketProxy < Proxy
    def initialize(maxTickets)
      super(Constants::ProxyConstants::TICKET_MASTER_PROXY)
      @masterCounter = 0
      @maxTickets = maxTickets
      @tickets = Array.new
      @masterMutex = Mutex.new
      
      for i in 0..maxTickets-1
        @tickets << Mutex.new
      end
    end
    
    def getTicket
      localIndex = -1
      @masterMutex.synchronize{
        localIndex = @masterCounter % @maxTickets
        @masterCounter = @masterCounter + 1
      }
      
      @tickets[localIndex].lock
      
      return localIndex
    end
    
    def returnTicket(ticketNumber)
      @tickets[ticketNumber].unlock
    end
  end
end