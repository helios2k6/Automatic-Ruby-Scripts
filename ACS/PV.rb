module PV
	require './Common'
	
	#Versions and such
	@REVISION = "201"
	@VERSION = "1.01"
	
	#Constants
	#COMPATIBILITY SETTINGS
	@XBOX = "xbox"
	@PS3 = "ps3"
	@IPHONE4 = "iphone4"
	
	#Arguments
	#File Location
	@KEYFRAME_FILE_ARG = "--keyframes"
	@INPUT_ARG = "--input"
	
	#Splitting arguments
	@SPLITS_ARG = "--splits"
	@EXCLUSION_ARG = "--exclude"
	
	#Video Specification Arguments
	@X264_CUSTOM_SETTINGS_ARG = "--x264"
	@RESOLUTION_ARG = "--resolution"
	
	#Compatibility
	@COMPATIBILITY_ARG = "--compat"
	
	#Output Arguments
	@OUTPUT_ARG = "--output"
	
	#Checksum flag
	@CHECKSUM_ARG = "--crc32"
	
	#Audio Argument
	@AUDIO_ARG = "--audio"
	
	#No-execute argument
	@NO_EXEC_ARG = "--no-exec"
	
	#Silence argument
	@SILENT_ARG = "--silent"
	
	#Shutdown agument
	@SHUTDOWN_ARG = "--shutdown"
	
	#@LOGGER Reference
	@LOGGER = Common.getLogger()
	
	#Print help
  def self.printHelp
    helpStrings = []
    helpStrings.push("Auto-Encoding System (ACS) v.#{@VERSION} r#{@REVISION}")
    helpStrings.push("Author: Andrew Johnson")
    helpStrings.push("")
    helpStrings.push("Usage: ruby THIS_SCRIPT.rb [options]")
    helpStrings.push("")
    helpStrings.push("Options:")
    
    helpStrings.push("")
    
    #Input
    helpStrings.push("\t--input")
    helpStrings.push("\t\tThe AVS file you want to use")
    
    helpStrings.push("")
    
    #Output
    helpStrings.push("\t--output")
    helpStrings.push("\t\tThe final output file")
    
    helpStrings.push("")
    
    #Splits
    helpStrings.push("\t--splits")
    helpStrings.push("\t\tThe amount of splits you want")
    
    helpStrings.push("")
    
    #Exclusion
    helpStrings.push("\t--exclude")
    helpStrings.push("\t\tRange of frames to exclude from the splits")
    
    helpStrings.push("")
    
    #Keyframes
    helpStrings.push("\t--keyframes")
    helpStrings.push("\t\tLocation of the keyframes file")
    
    helpStrings.push("")
    
    #Video Arguments
    helpStrings.push("\t--x264")
    helpStrings.push("\t\tLiteral x264 settings you want to use")
    
    helpStrings.push("")
    
    #Compatability
    helpStrings.push("\t--compat")
    helpStrings.push("\t\tCompatibility setting for a particular platform.")
    helpStrings.push("\t\tValid inputs: ps3, xbox, iphone4")
    
    helpStrings.push("")
    
    #Checksum flag
    helpStrings.push("\t--crc32")
    helpStrings.push("\t\tAttach CRC32 checksum to the output file name")
    
    helpStrings.push("")
    
    #Audio
    helpStrings.push("\t--audio")
    helpStrings.push("\t\tAudio file corresponding to the video")
    
    helpStrings.push("")
    
    #No Execute
    helpStrings.push("\t--no-exec")
    helpStrings.push("\t\tDo not execute any commands")
    
    helpStrings.push("")
    
    #Silent
    helpStrings.push("\t--silent")
    helpStrings.push("\t\tDon't output anything")
    
    helpStrings.push("")

    #Shutdown
    helpStrings.push("\t--shutdown")
    helpStrings.push("\t\tShutdown the computer after encoding")
    
    #Print
    helpStrings.each{|e| puts(e)}
  end
	
	#Universal error code nil will be passed back during error
	def self.execute(argv)
		argStruct = Common::ArgStruct.new
		@LOGGER.info("Evaluating Arguments")
		i = 0
		while i < argv.size
			currentArg = argv[i]
			currentValue = argv[i+1]
			
			case currentArg
			when @KEYFRAME_FILE_ARG
				if File.exists? currentValue then
					argStruct.keyframes = File.new(currentValue)
				else
					@LOGGER.error("Keyframe file doesn't exist")
					return nil
				end
				i = i + 2
			when @INPUT_ARG
				if File.exists? currentValue then
					argStruct.input = currentValue
				else
					@LOGGER.error("Input file doesn't exist")
					return nil
				end
				i = i + 2
			when @SPLITS_ARG
				begin
					argStruct.splits = Integer(currentValue)
				rescue ArgumentError
					@LOGGER.error("Must input integer for splits amount")
					return nil
				end
				i = i + 2
			when @EXCLUSION_ARG
				begin
				#handle this separately
				digits = currentValue.scan(/(\d+):(\d+)/)
				firstDigit = digits[0]
				secondDigit = digits[1]
				
				argStruct.addExclusionZone(Integer(firstDigit), Integer(secondDigit))
				rescue ArgumentError
					@LOGGER.error("Must input integers for exclusion zones")
					return nil
				end
				i = i + 2
			when @X264_CUSTOM_SETTINGS_ARG
				argStruct.x264Settings = currentValue
				i = i + 2
			when @COMPATIBILITY_ARG
				comparisonResult = currentValue.casecmp(@XBOX) & currentValue.casecmp(@PS3) & currentValue.casecmp(@IPHONE4)
				if comparisonResult == 0 then
					argStruct.addCompatibility(currentValue)
				else
					@LOGGER.error("Unknown compatibility setting #{currentValue}")
					return nil
				end
				i = i + 2
			when @OUTPUT_ARG
				argStruct.output = currentValue
				i = i + 2
			when @CHECKSUM_ARG
				argStruct.checksum = true
				i = i + 1
			when @AUDIO_ARG
				if File.exists? currentValue then
					argStruct.audio = currentValue
				else
					@LOGGER.error("Audio file doesn't exist")
					return nil
				end
				i = i + 2
			when @NO_EXEC_ARG
		        argStruct.noExec = true
        		i = i + 1
			when @SILENT_ARG
				argStruct.silent = true
				i = i + 1
			when @SHUTDOWN_ARG
				argStruct.shutdown = true
				i = i + 1
			else
				#print some help or something
				@LOGGER.error("Unknown argument #{currentArg}")
				return nil
			end
		end
		
		return argStruct
	end
end
