require 'Logger'

#Predefined constants
ARRAY_CEILING = (64 * (2**20))/8
LARGEST_RAND = 2**64 - 1

LOGGER = Logger.new(STDERR)
LOGGER.level = Logger::INFO
LOGGER.formatter = proc {|severity, datetime, progname, msg| "#{severity}: #{msg}\n"}

def runTest
	generateFile("test.bin", 8)
	
	open("test.bin"){|f|
		eightBytes = f.read(8).to_s
		LOGGER.info("Test result: #{eightBytes.unpack("Q*")}")
	}
	
end

def printHelp
	helpString = []
	
	helpString.push("Usage: ruby <this_script> <size of file in mebibytes> <file name>")
	
	for s in helpString
		puts s
	end
end

def outputBinaryToFile(file, array, currentFileSize, targetSize)
	file.print(array.pack("Q*"))
	LOGGER.info("Wrote #{array.size * 8} bytes. #{currentFileSize} / #{targetSize}")
end

def generateFile(fileName, fileSizeInBytes)
	timeStart = Time.new
	outputFile = IO.new(IO.sysopen(fileName, "ab"), "ab")
	
	largeIntegerArray = []
	
	LOGGER.info("Starting generation")
	
	currentFileSize = 0
	
	while currentFileSize < fileSizeInBytes
		randomSixtyFourBitInteger = rand(LARGEST_RAND)
		
		largeIntegerArray.push(randomSixtyFourBitInteger)
		
		if largeIntegerArray.size >= ARRAY_CEILING then
			outputBinaryToFile(outputFile, largeIntegerArray, currentFileSize, fileSizeInBytes)
			largeIntegerArray.clear
		end
		currentFileSize = currentFileSize + 8
	end
	
	if largeIntegerArray.size > 0 then
		outputBinaryToFile(outputFile, largeIntegerArray, currentFileSize, fileSizeInBytes)
	end
	timeEnd = Time.new
	
	outputFile.close
	
	LOGGER.info("Finished generating file in #{timeEnd - timeStart} seconds")
end

def main
	LOGGER.info("Random File Generator v1.0")
	if ARGV.size < 2 then
		printHelp
		exit
	end
	
	fileSize = ARGV[0].to_i * (2**20)
	
	LOGGER.info("Creating random filesize of #{ARGV[0]} Mebibytes")
	
	fileName = ARGV[1]
	
	generateFile(fileName, fileSize)
end

main
#runTest