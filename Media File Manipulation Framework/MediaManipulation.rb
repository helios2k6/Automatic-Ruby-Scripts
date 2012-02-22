require './MediaInfo'

module MediaManipulation
	#Constant names
	@MKV_EXTRACT = "mkvextract.exe"
	@MKV_MERGE = "mkvmerge.exe"
	
	@MP4BOX = "mp4box.exe"
	
	@FLAC = "flac.exe"
	
	@NEROAAC = "neroAacEnc"
	@NEROAAC_ENCODING_ARGS = "-lc -br 96000 -if "
	
	#Formats
	@MKV_FORMAT = "Matroska"
	@MP4_FORMAT = "MPEG-4"
	
	def self.decodeFlacTrack(flacFileName)
		expectedOutputFileName = File.basename(flacFileName, File.extname(flacFileName)) + ".wav"
		
		command = "#{FLAC} -d \"#{flacFileName}\""
		system(command)
		
		return expectedOutputFileName
	end
	
	def self.encodeWavToAac(wavFileName)
		outputFileName = File.basename(wavFileName, File.extname(wavFileName)) + "m4a"
		command = "#{NEROAAC} #{NEROAAC_ENCODING_ARGS} \"#{wavFileName}\" -of \"#{outputFileName}\""
		
		system(command)
		
		return outputFileName
	end
	
	def self.extractTrackMP4(mediaFile, track)
		command = "#{@MP4BOX} -raw #{track.trackNumber} \"#{mediaFile.fullPathFile}\""
		
		name = mediaFile.getName()
		
		system(command)
		
		extractedTrackFileName = "#{File.basename(name, File.extname(name))}_track#{track.trackNumber}"
		
		if track.format.casecmp("AVC") == 0 then
			extractedTrackFileName = extractedTrackFileName + ".h264"
		elsif track.format.casecmp("AAC") == 0 then
			extractedTrackFileName = extractedTrackFileName + ".aac"
		elsif track.format.casecmp("AC-3") == 0 then
			extractedTrackFileName = extractedTrackFileName + ".ac3"
		elsif track.format.casecmp("FLAC") == 0 then
			extractedTrackFileName = extractedTrackFileName + ".flac"
		end
		
		return extractedTrackFileName
	end
		
	def self.extractTrackMKV(mediaFile, track)
		name = mediaFile.getName()	
		
		baseCommand = command = "\"#{@MKV_EXTRACT}\" --ui-language en tracks \"#{mediaFile.fullPathFile}\" #{track.trackNumber - 1}:"
		
		outputFileName = File.basename(name, File.extname(name))
		
		case track.format
		when "AVC"
			outputFileName = outputFileName + ".h264"
		when "AAC"
			outputFileName = outputFileName + ".aac"
		when "AC-3"
			outputFileName = outputFileName + ".ac3"
		when "ASS"
			outputFileName = outputFileName + ".ass"
		when "UTF-8"
			outputFileName = outputFileName + ".srt"
		when "Vorbis"
			outputFileName = outputFileName + ".ogg"
		when "FLAC"
			outputFileName = outputFileName + ".flac"
		end
		
		baseCommand = baseCommand + "\"#{outputFileName}\""
		
		system(baseCommand)
		
		return outputFileName
	end
	
	def self.extractTrack(mediaFile, track)
		if mediaFile.is_a? MediaInfo::MediaFile then
			case mediaFile.getMediaType
			when @MKV_FORMAT
				return extractTrackMKV(mediaFile, track)
			when @MP4_FORMAT
				return extractTrackMP4(mediaFile, track)
			end
		end
	end
	
	def self.multiplexMP4(trackFileName, mp4FileName)
		command = "#{@MP4BOX} -add \"#{trackFileName}\" \"#{mp4FileName}\""
		
		system(command)
	end
end