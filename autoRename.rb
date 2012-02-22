require 'Zlib'
def main()
	cd = Dir.new(".")
	cd.each{|x| processFile(x)}
end

def processFile(file)
	extension = File.extname(file)
	base = File.basename(file, extension)
	if extension == ".mp4" then
		puts("Calculating CRC32 for #{file}")
		crc = getCRC32FromFile(file)
		newName = base + " [#{crc}]" + extension
		puts("Renaming file #{file} to #{newName}")
		File.rename(file, newName)
	end
end

# Better example
def getCRC32FromFile(fileName)
	file = IO.new(IO.sysopen(fileName, "rb"), "rb")
	
	chunk = file.read(512000)
	
	temp_crc = nil
	
	while chunk != nil
		temp_crc = Zlib.crc32(chunk, temp_crc)
		chunk = file.read(512000)
	end
	
	file.close
	
	crc =  temp_crc.to_s(16).upcase
	
	extraZeros = 8 - crc.length
	
	index = 0
	while(index < extraZeros)
		crc = "0" + crc
		index = index + 1
	end
	
	return crc
end

main