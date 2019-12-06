FLAC_BASE_COMMAND = "flac"
FLAC_ARGS = " -d "
FLAC_EXTENSION = ".flac"
WAV_EXTENSION = ".wav"

NERO_AAC_BASE_COMMAND = "neroAacEnc"
BITRATE = 96000 #96k
NERO_ENCODING_ARGS = "-lc -br #{BITRATE} -if "
AAC_EXTENSION = ".m4a"

def extractFlac(fileName)
	outputFileName = "#{File.basename(fileName, FLAC_EXTENSION)}#{WAV_EXTENSION}"
	extractionCommand = "#{FLAC_BASE_COMMAND} #{FLAC_ARGS} \"#{fileName}\""
	
	puts extractionCommand
	system(extractionCommand)
	
	return outputFileName
end

def encodeAac(fileName)
	outputFileName = "#{File.basename(fileName, WAV_EXTENSION)}#{AAC_EXTENSION}"
	
	encodingCommand = "#{NERO_AAC_BASE_COMMAND} #{NERO_ENCODING_ARGS} \"#{fileName}\" -of \"#{outputFileName}\""
	
	puts encodingCommand
	system(encodingCommand)

	return outputFileName
end

def processFile(fileName)
	fileExtension = File.extname(fileName)
	
	if fileExtension.casecmp(".flac") == 0 then
		extractedWav = extractFlac(fileName)
		encodedAac = encodeAac(extractedWav)
		
		File.delete(extractedWav)
		
		return encodedAac
	end
	
	return nil
end

def processAllFiles
	cd = Dir.new(".")
	cd.each{|file|
		encodedFile = processFile(file)
	}
end

def main
	processAllFiles
end

main
