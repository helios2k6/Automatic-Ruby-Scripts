Semaphore = Mutex.new

def ping(ip)
	result = %x(ping 192.168.1.#{ip})
	Semaphore.synchronize{
		puts(result)
	}
end

def main
	allThreads = []
	t = Thread.new{
		for i in 100..109
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 110..119
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 120..129
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 130..139
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 140..149
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 150..159
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 160..169
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 170..179
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 180..189
			ping(i)
		end
	}
	allThreads.push(t)
		t = Thread.new{
		for i in 190..200
			ping(i)
		end
	}
	allThreads.push(t)

	for t in allThreads
		t.join
	end
end

main