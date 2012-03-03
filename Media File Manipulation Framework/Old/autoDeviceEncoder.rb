#Steps
# 1. Detect what type of file it is
# 2. If MKV, see if we need to extract a subtitle file
# 3. Once that's done, create an avsynth file
# 4. Execute x264 command
# 5. Detect if there's an audio-track we can demultiplex. If so, be sure to multiplex it
# 6. Remultiplex it using MP4Box

require './MediaManipulation'
require './AVS'
require 'Logger'
require 'thread'

LOGGER = Logger.new(STDERR)
LOGGER.level = Logger::INFO
LOGGER.formatter = proc {|severity, datetime, progname, msg| "#{severity}: #{msg}\n"}

X264_ENCODING_COMMAND_IPHONE = "x264 --crf 21 --deblock 2:2 --psy-rd 0.4 --level 3.1 --profile main --b-pyramid none --bframes 16 --sar 1:1 --ssim --psnr --non-deterministic"
X264_ENCODING_COMMAND_PS3 = "x264 --crf 21 --deblock 2:2 --psy-rd 0.4 --level 4.2 --profile high --aud --sar 1:1 --vbv-maxrate 31250 --vbv-bufsize 31250 --b-pyramid none --bframes 16 --sar 1:1 --ssim --psnr --non-deterministic"

FILE_ARG = "--files"
DEVICE_ARG = "--device"
AVS_ADD_ARG = "--avs-add"
NO_MUX_ARG = "--no-mux"
HELP_ARG = "--help"

FORCE_AUDIO_TRACK = "--audio-track"
FORCE_SUBTITLE_TRACK = "--subtitle-track"

BLACKLIST_ARG = "--blacklist"

COUNT_MUTEX = Mutex.new
MAX_MUTEXES = 1
GLOBAL_MUTEX_ARRAY = []
for i in 1..MAX_MUTEXES
	GLOBAL_MUTEX_ARRAY.push(Mutex.new)
end

class ProgramArgs
	attr_accessor :device, :files, :avsCommands, :noMultiplex, :audioTrack, :subtitleTrack, :blacklist
	
	def initialize()
		@device = "ps3"
		@files = "all"
		@avsCommands = nil
		@noMultiplex = false
		@audioTrack = nil
		@subtitleTrack = nil
		@blacklist = []
	end
end

def printHelp
	helpString = []
	
	helpString.push("Auto Device Encoder")
	helpString.push("Author: Andrew Johnson")
	helpString.push("")
	
	helpString.push("Usage: ruby autoDeviceEncoder.rb [options]")
	helpString.push("")
	
	helpString.push("Options:")
	helpString.push("")
	
	#Options
	
	#Help
	helpString.push("\t#{HELP_ARG}")
	helpString.push("\t\tPrint this help screen")
	helpString.push("")
	
	#Files
	helpString.push("\t#{FILE_ARG} [<file 1>;<file 2>;...]")
	helpString.push("\t\tThe name(s) of the media files you want to encode")
	helpString.push("\t\tAllowed to put \"all\" to specify all media files in current dir")
	helpString.push("")
	
	#Blacklist
	helpString.push("\t#{BLACKLIST_ARG} [<file 1>;<file 2>;...]")
	helpString.push("\t\tThe name(s) of the files you want to explicitly blacklist")
	helpString.push("\t\tCan be used in conjunction with a list of files that have been whitelisted")
	helpString.push("\t\tThe blacklist takes precedence over the whitelist")
	helpString.push("")
	
	#Device type
	helpString.push("\t#{DEVICE_ARG} <string>")
	helpString.push("\t\tSpecifies the device to encode for")
	helpString.push("\t\tValid inputs: ps3, iphone4")
	helpString.push("")
	
	#Filters
	helpString.push("\t#{AVS_ADD_ARG} {<string 1>;<string 2>;<string 3>}")
	helpString.push("\t\tAdds extra lines into the avisynth file")
	helpString.push("")
	
	#No-Mux
	helpString.push("\t#{NO_MUX_ARG}")
	helpString.push("\t\tDon't multiplex the raw video")
	helpString.push("")
	
	#Force audio track
	helpString.push("\t#{FORCE_AUDIO_TRACK}")
	helpString.push("\t\tUse specified track for audio")
	helpString.push("")
	
	#Force subtitle track
	helpString.push("\t#{FORCE_SUBTITLE_TRACK}")
	helpString.push("\t\tUse specified track for subtitle")
	helpString.push("")
	
	helpString.each{|e| puts e}
end

#Goes through the list of tracks of a media file and returns the track number
#of the subtitle track. 
#If there is more than one subtitle track, then
def searchForSubtitleTrack(mediaFile)
	tracks = mediaFile.tracks
	subtitleTrack = nil
	lastFormat = "none"
	for mediaTrack in tracks	
		if mediaTrack.trackType.casecmp("text") == 0 then
			if mediaTrack.format.casecmp("ASS") == 0 then
				subtitleTrack = mediaTrack
			elsif mediaTrack.format.casecmp("UTF-8") == 0 && subtitleTrack == nil then
				subtitleTrack = mediaTrack
			end
		end
	end
	
	return subtitleTrack
end

def searchForAudioTrack(mediaFile, aacOnly=false)
	tracks = mediaFile.tracks
	audioTrack = nil
	
	for mediaTrack in tracks
		type = mediaTrack.trackType
		
		if type.casecmp("audio") == 0 then		
			if mediaTrack.format.casecmp("AAC") == 0 || (mediaTrack.format.casecmp("AC-3") == 0 && !aacOnly) then
				audioTrack = mediaTrack
			end
		end
	end
	
	return audioTrack
end

def extractSubtitleAndAudioTracks(mediaFile, programArgs)
	extractedTracks = []
	
	aacOnly = programArgs.device.casecmp("iphone4") == 0
	
	LOGGER.info("Searching for tracks")
	
	audioTrack = nil
	subtitleTrack = nil
	
	if programArgs.audioTrack == nil then
		audioTrack = searchForAudioTrack(mediaFile, aacOnly)
	else
		audioTrack = mediaFile.getTrack(programArgs.audioTrack)
	end
	
	if programArgs.subtitleTrack == nil then
		subtitleTrack = searchForSubtitleTrack(mediaFile)
	else
		subtitleTrack = mediaFile.getTrack(programArgs.subtitleTrack)
	end
		
	if subtitleTrack != nil then
		LOGGER.info("Found subtitle track. Track ID = #{subtitleTrack.trackNumber}")
		subtitleFile = MediaManipulation.extractTrack(mediaFile, subtitleTrack)
		extractedTracks.push(subtitleFile)
	else
		extractedTracks.push(nil)
	end
	
	if audioTrack != nil then
		LOGGER.info("Found audio track. Track ID = #{audioTrack.trackNumber}")
		audioFile = MediaManipulation.extractTrack(mediaFile, audioTrack)
		extractedTracks.push(audioFile)
	else
		extractedTracks.push(nil)
	end
		
	return extractedTracks
end

def createAvisynthFile(fileName, subtitleFile=nil, userFilters=nil)
	avisynthFile = nil
	extraFilters = nil
	
	LOGGER.info("Generating Avisynth file")
	
	if subtitleFile != nil then
		extraFilters = "textsub(\"#{subtitleFile}\")\n"
	end
	
	if userFilters != nil then
		extraFilters = "#{extraFilters}#{userFilters}\n"
	end
	
	return AVS.generateAVSFile(fileName, extraFilters)
end

def encodeAvisynthScript(avisynthFile, mode)
	LOGGER.info("Encoding Avisynth file")
	
	outputFileName = File.basename(avisynthFile, File.extname(avisynthFile)) + ".264"
	command = ""
	
	if mode.casecmp("iphone4") == 0 then
		command = "#{X264_ENCODING_COMMAND_IPHONE} --output \"#{outputFileName}\" \"#{avisynthFile}\""
	else
		command = "#{X264_ENCODING_COMMAND_PS3} --output \"#{outputFileName}\" \"#{avisynthFile}\""
	end
	
	LOGGER.info("Executing command: #{command}")
	
	system(command)
	
	return outputFileName
end

def processFile(file, programArgs)
	basename = File.basename(file)
	
	filesToDelete = []

	LOGGER.info("Processing file #{file}")
	
	LOGGER.info("Gathering media info")
	mediaFile = MediaInfo.getMediaInfo(file)
	
	#Extract stuff if we need to
	LOGGER.info("Extracting subtitle and audio tracks")
	extractedFile = extractSubtitleAndAudioTracks(mediaFile, programArgs)

	
	LOGGER.info("Creating Avisynth file")
	avisynthFile = nil
	#Create avisynth file
	if extractedFile[0] != nil then
		#Subtitle track detected
		LOGGER.info("Subtitle track detected")
		avisynthFile = createAvisynthFile(mediaFile.fullPathFile, extractedFile[0], programArgs.avsCommands)
		
		filesToDelete.push(extractedFile[0])
	else
		LOGGER.info("No subtitle track detected")
		avisynthFile = createAvisynthFile(mediaFile.fullPathFile, nil, programArgs.avsCommands)
	end
	
	filesToDelete.push(avisynthFile)
	
	#execute encode
	LOGGER.info("Executing encode")
	encodedOutputFileName = encodeAvisynthScript(avisynthFile, programArgs.device)	
	outputName = "#{File.basename(file, File.extname(file))}_ADE.mp4"
	
	#remultiplex
	if extractedFile[1] != nil && !programArgs.noMultiplex then
		LOGGER.info("Multiplexing MP4 file")
		MediaManipulation.multiplexMP4(encodedOutputFileName, outputName)
		MediaManipulation.multiplexMP4(extractedFile[1], outputName)
		LOGGER.info("Output file is: #{outputName}")
		
		filesToDelete.push(extractedFile[1])
		filesToDelete.push(encodedOutputFileName)
	else
		LOGGER.info("Skipping multiplexing")
		LOGGER.info("Output file is: #{encodedOutputFileName}")
	end
	
	#Add index file
	filesToDelete.push("#{file}.ffindex")
	
	#delete junk
	for f in filesToDelete
		File.delete(f)
	end

end

def filterFiles(dir, blacklist)
	LOGGER.info("Filtering files")
	files = []
	
	dir.each{|file| 
		extension = File.extname(file)
		if (extension.casecmp(".mkv") == 0 || extension.casecmp(".mp4") == 0) && (!blacklist.include?(file)) then
			files.push(file)
			LOGGER.info("Discovered the file: #{file}")
		end
	}
	
	return files
end

def processAllFiles(programArgs)
	filteredFiles = []
	threads = []
	
	if programArgs.files[0].casecmp("all") == 0 then
		cd = Dir.new(".")
		filteredFiles = filterFiles(cd, programArgs.blacklist)
	else
		filteredFiles = filterFiles(programArgs.files, programArgs.blacklist)
	end
	
	current_count = 0
	
	filteredFiles.each{|file| 
		threads << Thread.new{
		
			COUNT_MUTEX.lock
			chosenMutex = current_count % MAX_MUTEXES
			current_count = current_count + 1
			COUNT_MUTEX.unlock
			
			GLOBAL_MUTEX_ARRAY[chosenMutex].lock
			processFile(file, programArgs)
			GLOBAL_MUTEX_ARRAY[chosenMutex].unlock
		}
	}
	
	threads.each{|thread|
		thread.join
	}
end

def doesUserWantHelp(argVector)
	for a in argVector
		if a.casecmp(HELP_ARG) == 0 then
			return true
		end
	end
	
	return false
end

def generateAvsStringFromFilterList(listOfFilters)
	avsFilterString = ""
	
	listOfFilters.map{|filter| avsFilterString.concat("#{filter} \n")}
	
	return avsFilterString
end

def processArgs(argVector)
	if argVector.size < 2 || doesUserWantHelp(argVector) then
		printHelp
		exit
	end
	
	programArgs = ProgramArgs.new()
	
	begin
		i = 0
		while i < argVector.size
			currentArg = argVector[i]
			increment = 2
			case currentArg
				when FILE_ARG
					programArgs.files = argVector[i+1].split(";")
				when DEVICE_ARG					
					programArgs.device = argVector[i+1]
				when AVS_ADD_ARG					
					programArgs.avsCommands = generateAvsStringFromFilterList(argVector[i+1].split(";"))
				when NO_MUX_ARG					
					programArgs.noMultiplex = true
					increment = 1
				when FORCE_AUDIO_TRACK
					programArgs.audioTrack = argVector[i+1].to_i
				when FORCE_SUBTITLE_TRACK
					programArgs.subtitleTrack = argVector[i+1].to_i
				when BLACKLIST_ARG
					programArgs.blacklist = argVector[i+1].split(";")
			end
			
			i = i + increment
		end
	rescue
		LOGGER.error("An argument could not be parsed")
		LOGGER.error($!)
		printHelp
		exit(1)
	end
		
	LOGGER.info("Chosen device #{programArgs.device}")
	
	#AVS Filters
	if programArgs.avsCommands != nil then
		LOGGER.info("Extra AVS Filters to be applied:\n\n#{programArgs.avsCommands}")
	end
		
	#Info
	if programArgs.noMultiplex then
		LOGGER.info("Not multiplexing the file")
	end
	
	#Audio track
	if programArgs.audioTrack != nil then
		LOGGER.info("Using Audio at Track ##{programArgs.audioTrack}")
	end
	
	#Subtitle track
	if programArgs.subtitleTrack != nil then
		LOGGER.info("Using Subtitles at Track ##{programArgs.subtitleTrack}")
	end

	return programArgs
end

def main
	LOGGER.info("Starting Auto Device Encoder")	
	programArgs = processArgs(ARGV)
	
	processAllFiles(programArgs)
end

main