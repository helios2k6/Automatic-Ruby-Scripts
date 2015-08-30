require 'socket'
#LARGEST_DATA = 4096
LARGEST_DATA = 25600
LARGEST_RAND = 2**64 - 1

def generateBytes()
	puts("Generating data")
	largeIntegerArray = []
	
	i = 0

	while i < LARGEST_DATA
		randomSixtyFourBitInteger = rand(LARGEST_RAND)
		
		largeIntegerArray.push(randomSixtyFourBitInteger)
		i = i + 8
	end
	return largeIntegerArray.pack("N*")
end

def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
ensure
  Socket.do_not_reverse_lookup = orig
end

def setupSocket(portNumber)
	socket = UDPSocket.new
	currentIP = local_ip

	puts("Current local IP address #{currentIP}")

	socket.bind(currentIP, portNumber)
	return socket
end

def sendInfiniteTraffic(socket, msg, flags, host, port)
	puts("Sending data to #{host}:#{port}")
	#bytesCounter = 0
	#kibiBytes = 0
	while 1
		#bytesCounter = bytesCounter + socket.send(msg, flags, host, port)
		socket.send(msg, flags, host, port)
		#if bytesCounter > 1024 then
		#	kibiBytes = kibiBytes + 1
		#	bytesCounter = bytesCounter % 1024

		#	puts("Sent #{kibiBytes} kibibytes so far")
		#end
	end
end

def receiveInfiniteTraffic(socket)
	kibibyteCounter = 0
	while 1
		begin
			socket.recvfrom_nonblock(1024)
		rescue
		end		
	end
end

def main
	puts("Ruby Network Nuker v1.0")
	puts("Enter in the port number: ")
	portNumber = gets.chomp.to_i
	
	socket = setupSocket(portNumber)
	
	puts("Is this a client or server?")
	choice = gets.chomp

	puts("You chose \"#{choice}\"")

	case(choice)
	when "server"
		puts("Initiating reception")
		receiveInfiniteTraffic(socket)
	when "client"
		puts("Where do you want to send data?")
		destHost = gets.chomp
		
		puts("Which port do you want to send to?")
		destPort = gets.chomp.to_i

		msg = generateBytes()

		puts("Sending nukes")
		sendInfiniteTraffic(socket, msg, 0, destHost, destPort)
	end
end

main