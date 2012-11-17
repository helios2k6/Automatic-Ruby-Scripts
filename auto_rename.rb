FILE_VERIFIER_COMMAND = "fvc -c -a CRC32"

def main()
	cd = Dir.new(".")
	cd.each{|x| processFile(x)}
end

def processFile(file)
	extension = File.extname(file)
	base = File.basename(file, extension)
	if extension == ".mp4" then
		puts("Calculating CRC32 for #{file}")
		crc = calculateHashWithFileVerifier(file)
		newName = base + " [#{crc}]" + extension
		puts("Renaming file #{file} to #{newName}")
		File.rename(file, newName)
	end
end

def calculateHashWithFileVerifier(fileName)
	command = "#{FILE_VERIFIER_COMMAND} \"#{fileName}\""
	
	puts("Executing command #{command}")
	
	#output = %x("command")
	
	output = IO.popen(command)
	
	stringOutput = output.readlines[2]
	
	parsedHash = stringOutput.split(" ?")[0]
	
	return parsedHash.upcase
end

main