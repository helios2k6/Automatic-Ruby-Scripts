load "./imports.rb"



def validateLogic(argStruct)
	logger = Common.getLogger
	#Need to have input and output
	if argStruct.output == nil || argStruct.input == nil then
		return false
	end
	
	#Check output type
	if argStruct.getMediaOutputType != ".264" then
		#Must have an audio file if we plan on outputting an MP4 or MKV
		if argStruct.audio == nil then
			logger.error("No audio file detected. Cannot multiplex MP4 or MKV without an audio file")
		elsif !File.exists?(argStruct.audio) then
		  logger.error("Audio file doesn't exist")
		end
	end
	
	#Check split logic
	if argStruct.splits != nil && argStruct.splits > 1 then
	  if argStruct.keyframes == nil || !File.exists?(argStruct.keyframes) then
	    logger.error("Keyframe file is null or doesn't exit")
	    return false
	  end
	end
	
	return true 
end

def noExec(argStruct)
  
end

def execute(args)
	logger = Common.getLogger
	argStruct = PV.execute(args)
	
	if argStruct == nil then
		logger.error("Could not parse aguments")
		PV.printHelp
		return 
	end
	
	if args.size == 0 then
	  PV.printHelp
	  return
	end
	
	#Validate argument structure here
	if !validateLogic(argStruct) then
	  logger.error("Invalid argument logic")
	  PV.printHelp
	  return
	end
	
	#Check logic
	if argStruct.splits == nil || argStruct.splits <= 1 then
	  #Encoding using one split
		logger.info("Detected no-split encode. Diverting to immediate encode")
		# Skip Splits calculation
		argStruct.splits = 1
		logger.info("Beginning encode")
		EE.executeWithoutSplits(argStruct)
		
	else
	  #Encoding using multiple splits
	  logger.info("Detected encode with #{argStruct.splits} splits")
	  logger.info("Calculating split data")
	  splits = SC.execute(argStruct)
	  
	  #Encode using split logic
	  logger.info("Beginning encode")
	  EE.execute(argStruct, splits)
	end
end

def main
	logger = Common.getLogger
	argStruct = PV.execute(ARGV)
	
	if argStruct == nil then
		logger.error("Could not parse aguments")
		PV.printHelp
		return 
	end
	
	if ARGV.size == 0 then
	  PV.printHelp
	  return
	end
	
	#Validate argument structure here
	if !validateLogic(argStruct) then
	  logger.error("Invalid argument logic")
	  PV.printHelp
	  return
	end
	
	#Check logic
	if argStruct.splits == nil || argStruct.splits <= 1 then
	  #Encoding using one split
		logger.info("Detected no-split encode. Diverting to immediate encode")
		# Skip Splits calculation
		argStruct.splits = 1
		logger.info("Beginning encode")
		EE.executeWithoutSplits(argStruct)
		
	else
	  #Encoding using multiple splits
	  logger.info("Detected encode with #{argStruct.splits} splits")
	  logger.info("Calculating split data")
	  splits = SC.execute(argStruct)
	  
	  #Encode using split logic
	  logger.info("Beginning encode")
	  EE.execute(argStruct, splits)
	end
end

main