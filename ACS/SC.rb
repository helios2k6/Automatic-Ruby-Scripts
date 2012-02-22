module SC
	require './Common'
	
	#Logger
	@LOGGER = Common.getLogger()
	
	class KeyframeDatabase
		#Internal Constant
		@@Infinity = 1.0/0
		attr_accessor :arrayOfIFrames, :totalNumberOfFrames
		
		def initialize(arrayOfIFrames, totalNumberOfFrames)
			@arrayOfIFrames = arrayOfIFrames
			@totalNumberOfFrames = totalNumberOfFrames
		end
		
		def getTotalNumberOfFrames
			return @totalNumberOfFrames
		end
		
		def getKeyFrames
			return @arrayOfIFrames
		end
		
		def getNearestIFrame(frame)
			if frame > @totalNumberOfFrames then 
				raise "Requested frame greater than total amount of frames"
			elsif frame == 0 then
				return 0
			end
			
			closestDistance = @@Infinity
			closestIFrame = 0
			for i in @arrayOfIFrames
				localDist = (frame - i).abs
				
				if(localDist < closestDistance) then
					closestDistance = localDist
					closestIFrame = i
				end
			end
			return closestIFrame
		end
		
		def getNextIFrame(offset)	
			closestDistance = @@Infinity
			
			i = 0
			while i < @totalNumberOfFrames
				currentFrame = @arrayOfIFrames[i]
				if currentFrame > offset then
					return currentFrame
				end
				i = i + 1
			end
		end
	end
	
	def self.locateKeyframes(keyframeFileName)
		arrayOfFrames = Array.new
		index = 0
		count = 0;
		keyframeFile = IO.new(IO.sysopen(keyframeFileName, "r"))
		
		line = keyframeFile.gets
		while line != nil
			result = line.scan(/(type:I)/)
			if result.size > 0 then
				frameNumber = line.scan(/(in:)(\d+)/)
				arrayOfFrames.push(Integer(frameNumber[0][1]))
			end
			
			isFrame = line.scan(/(type:)/)
			if isFrame.size > 0 then
				count = count + 1
			end
			
			line = keyframeFile.gets
			index = index + 1
		end
		
		keyframeDB = KeyframeDatabase.new(arrayOfFrames, count)
		
		return keyframeDB
	end

	def self.isInExclusiveZone(exclusiveZones, frame)
		i = 0
		
		while i < exclusiveZones.size
			exclusiveStart = exclusiveZones[i]
			exclusiveEnd = exclusiveZones[i+1]
			if frame >= exclusiveStart && frame < exclusiveEnd then
				return true
			end
			i = i + 2
		end
		
		return false
	end

	def self.calcSplits(splits, exclusiveZones, keyFrameDatabase)
		#Sanity checks
		if(splits >= keyFrameDatabase.getTotalNumberOfFrames)
			puts("More splits than total number of frames")
			exit
		end
		
		takenFrames = Array.new
		
		#add start frame
		takenFrames.push(0)
		
		#add end frame
		takenFrames.push(keyFrameDatabase.getTotalNumberOfFrames-1)
		
		#add exclusive frames
		for i in exclusiveZones
			takenFrames.push(i)
		end
		
		chunkSize = keyFrameDatabase.getTotalNumberOfFrames / splits
		
		i = 1
		
		while i < splits
			predictedFrame = keyFrameDatabase.getNearestIFrame(i * chunkSize)
			
			if isInExclusiveZone(exclusiveZones, predictedFrame) then
				#We're in an exclusive zone. Get the nearest iframe
				while true
					predictedFrame = keyFrameDatabase.getNextIFrame(predictedFrame)
					if !isInExclusiveZone(exclusiveZones, predictedFrame) then
						break
					end
				end		
			end
			
			takenFrames.push(predictedFrame)
			
			i = i + 1
		end
		
		return takenFrames.sort!
	end
	
	def self.execute(argStruct)
		@LOGGER.info("Calculating splits")
		keyframeDB = locateKeyframes(argStruct.keyframes)
		@LOGGER.info("Hydrated keyframe database")
		splits = calcSplits(argStruct.splits, argStruct.exclusionZones, keyframeDB)
		@LOGGER.info("Calculated splits")
		
		return splits
	end
end