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