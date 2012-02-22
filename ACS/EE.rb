module EE
	require './Common'
	require 'Zlib'
	require 'timeout'
	
	@PS3_COMPAT_SETTINGS = "--level 4.2 --profile high --aud --sar 1:1 --vbv-bufsize 31250 --vbv-maxrate 31250"
	@XBOX_COMPAT_SETTINGS = "--level 4.1 --profile high --aud --sar 1:1 --vbv-bufsize 24000 --vbv-maxrate 24000"
	@IPHONE4_COMPAT_SETTINGS = "--level 3.1 --profile main --sar 1:1 --vbv-bufsize 10000 --vbv-maxrate 10000"
	
	@LOGGER = Common.getLogger()
	
	@X264_COMMAND = "x264"
	
	@CAT_COMMAND = "cat"
	
	@MP4BOX_COMMAND = "MP4Box.exe"
	
	@MKVMERGE_COMMAND = "mkvmerge.exe"
	
	@PARTIAL_ENCODE_NAME = "#{(0..8).map{65.+(rand(25)).chr}.join} - part"
	
	@TOTAL_ENCODE_NAME = "#{(0..8).map{65.+(rand(25)).chr}.join} - total"
	
	@X264_EXTENTION = ".264"
	
	@TEMP_MKV_FILE_NAME = "total_temp - #{(0..8).map{65.+(rand(25)).chr}.join}.mkv"
	
	@TEMP_MP4_FILE_NAME = "total_temp - #{(0..8).map{65.+(rand(25)).chr}.join}.mp4"
	
	def self.formMKVMergeCommand(video_bit_stream, audio_file)
		
	end
	
	def self.shutdownComputer
		@LOGGER.info("Shutting down computer in 10 seconds. Hit Enter to abort")
		begin
			status = timeout(10){
				gets.chomp
			}
			
			@LOGGER.info("Shutdown aborted. Exiting")
		rescue
			@LOGGER.info("Shutting down computer")
			system("Shutdown.exe -s -t 5")
		end
	end

	def self.cleanup(fileList)
		@LOGGER.info("Deleting files")
	
		for file in fileList
			begin
				@LOGGER.info("Deleting file #{file}")
				File.delete(file)
			rescue exception
				@LOGGER.error("Exception while deleting file #{file}")
				@Logger.error(exception)
			end
		end
	end
	
	def self.detectLowestCompatibilitySetting(compat)
		level = 0
		for setting in compat		
			if setting.casecmp("ps3") == 0 && level == 0 then
				level = 0
			elsif setting.casecmp("xbox") == 0 && level <= 1 then
				level = 1
			else
				level = 2
			end
		end

		case level
			when 0
				return @PS3_COMPAT_SETTINGS
			when 1
				return @XBOX_COMPAT_SETTINGS
			else
				return @IPHONE4_COMPAT_SETTINGS
		end
	end
	
	def self.getCRC32FromFile(fileName)
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
		end
		
		return crc
	end
	
	def self.executeWithoutSplits(argStruct)
		#Find seek points and frame amounts
		filesToDelete = []
		rootCommand = @X264_COMMAND + " #{argStruct.x264Settings}"
		
		if argStruct.compat.size > 0 then
		  @LOGGER.info("Detecting lowest compatibility setting")
			compat_settings = detectLowestCompatibilitySetting(argStruct.compat)
			rootCommand = rootCommand + " #{compat_settings}"
		end
		
		command = rootCommand + " --output \"#{@TOTAL_ENCODE_NAME+@X264_EXTENTION}\" \"#{argStruct.input}\""
		
		@LOGGER.info("Executing command #{command}")
		
		system(command)
			
		tempName = nil
		
		#Handle multiplexing logic here
		case argStruct.getMediaOutputType
			when ".mkv"
				#Look this up later
				@LOGGER.info("Multiplexing to MKV")

			when ".mp4"
			  @LOGGER.info("Multiplexing to MP4")
				tempName = @TEMP_MP4_FILE_NAME
				muxingCommand = @MP4BOX_COMMAND + " -add \"#{@TOTAL_ENCODE_NAME}#{@X264_EXTENTION}\" -add \"#{argStruct.audio}\" -new \"#{tempName}\""
				system(muxingCommand)
				filesToDelete.push(@TOTAL_ENCODE_NAME+@X264_EXTENTION)
			else
				#do nothing. leave as .264
				@LOGGER.info("No multiplexing")
				tempName = @TOTAL_ENCODE_NAME + @X264_EXTENTION
		end
		#By now, we expect the multiplexing to be complete
		
		#Rename here
		@LOGGER.info("Renaming file")
		finalName =  File.basename(argStruct.output, argStruct.getMediaOutputType)
		
		if argStruct.checksum then
		  @LOGGER.info("Calculating CRC32 Checksum")
			finalName = finalName + " [#{getCRC32FromFile(tempName)}]"
		end
		
		finalName = finalName + argStruct.getMediaOutputType
		
		#Renaming
		@LOGGER.info("Renaming final file")
		File.rename(tempName, finalName)
		
		#Cleanup
		if filesToDelete.size() > 0 then
			cleanup(filesToDelete)
		end
		
		if argStruct.shutdown then
			shutdownComputer()
		end
	
	end
	
	def self.execute(argStruct, splits)
		filesToDelete = []
		#Find seek points and frame amounts
		i = 0
		
		seekArray = []
		frameAmounts = []
		@LOGGER.info("Using the following split calculation")
		while i < splits.size - 1
			seekArray[i] = splits[i]
			frameAmounts[i] = splits[i+1] - splits[i]
			@LOGGER.info("[#{splits[i]},\t#{splits[i+1]})\tDiff=#{splits[i] - splits[i+1]}")
			i = i + 1
		end
	
		rootCommand = @X264_COMMAND + " #{argStruct.x264Settings}"
		
		if argStruct.compat.size > 0 then
			compat_settings = detectLowestCompatibilitySetting(argStruct.compat)
			rootCommand = rootCommand + " #{compat_settings}"
		end
		
		commandArray = []
		
		fileNameArray = []
		i = 0
		while i < seekArray.size
			fileName = "#{@PARTIAL_ENCODE_NAME} - #{i}#{@X264_EXTENTION}"
			fileNameArray.push(fileName)
			filesToDelete.push(fileName)
			commandArray.push(rootCommand + " --seek #{seekArray[i]} --frames #{frameAmounts[i]} --output \"#{fileName}\" \"#{argStruct.input}\"")
			i = i + 1
		end
		
		#Concatonation step here
		#Add logic to prevent Cat if there's only 1 split
		if argStruct.splits != 1 then
			catCommand = @CAT_COMMAND
			
			for files in fileNameArray
				catCommand = catCommand + " \"#{files}\""
			end
			
			catCommand = catCommand + " > \"#{@TOTAL_ENCODE_NAME}#{@X264_EXTENTION}\""
			
			commandArray.push(catCommand)
		end
		
		#Execute commands. We can't handle the multiplexing logic until later
		for command in commandArray
			@LOGGER.info("Executing command #{command}")
			system(command)
		end
		
		#Add logic to detect 1 split and rename
		if argStruct.splits == 1 then
			File.rename(fileNameArray[0], @TOTAL_ENCODE_NAME+@X264_EXTENTION)
		end
			
		tempName = nil
		
		#Handle multiplexing logic here
		case argStruct.getMediaOutputType
			when ".mkv"
				#Look this up later
				@LOGGER.info("Multiplexing to MKV")
				tempName = @TOTAL_ENCODE_NAME + @X264_EXTENTION
			when ".mp4"
			  @LOGGER.info("Multiplexing to MP4")
				tempName = @TEMP_MP4_FILE_NAME
				muxingCommand = @MP4BOX_COMMAND + " -add \"#{@TOTAL_ENCODE_NAME}#{@X264_EXTENTION}\" -add \"#{argStruct.audio}\" -new \"#{tempName}\""
				system(muxingCommand)
				filesToDelete.push(@TOTAL_ENCODE_NAME+@X264_EXTENTION)
			else
				#do nothing. leave as .264
				@LOGGER.info("No multiplexing")
				tempName = @TOTAL_ENCODE_NAME + @X264_EXTENTION
		end
		
		#By now, we expect the multiplexing to be complete
		finalName =  File.basename(argStruct.output, argStruct.getMediaOutputType)
		
		if argStruct.checksum then
		  @LOGGER.info("Calculating CRC32 Checksum")
			finalName = finalName + " [#{getCRC32FromFile(tempName)}]"
		end
		
		finalName = finalName + argStruct.getMediaOutputType
		
		#Renaming
		@LOGGER.info("Renaming final file")
		File.rename(tempName, finalName)
		
		#Cleanup
		cleanup(filesToDelete)
				
		if argStruct.shutdown then
			shutdownComputer()
		end
	end
end
