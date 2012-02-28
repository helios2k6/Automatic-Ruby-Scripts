require './Constants'
require './MediaObjects'
require 'PureMVC_Ruby'

module MediaTaskObjects
	class EncodingJobsProxy < Proxy
		def initialize
			super(ProxyConstants::ENCODING_JOBS_PROXY)
			@encodingJobs = []
		end
		
		def addEncodingJob(encodingJob)
			@encodingJobs << encodingJob
		end
		
		def getNextEncodingJob
			return @encodingJobs.delete(0)
		end
		
		def hasNextJob
			return !@encodingJobs.empty?
		end
	end

	class EncodingConstants
		X264 = "x264.exe"
		
		PS3_CONSTANT = "ps3"
		IPHONE4_CONSTANT = "iphone4"
		
		DEVICE_VECTOR = [PS3_CONSTANT, IPHONE4_CONSTANT]
		
    QUALITY_LOW = "--crf 24"
    
    QUALITY_MEDIUM = "--crf 22 --subme 8"
    
    QUALITY_HIGH = "--crf 20 --subme 9"
    
    QUALITY_VERY_HIGH = "--crf 18 --subme 10 --trellis 2"
    
		PS3_COMPAT_ARGS = "--level 4.2 --profile high --aud --sar 1:1 --vbv-maxrate 31250 --vbv-bufsize 31250 "
		IPHONE4_COMPAT_ARGS = "--level 3.1 --profile main --sar 1:1"
		
		DEVICE_COMPAT_HASH=[PS3_CONSTANT => PS3_COMPAT_ARGS, IPHONE4_CONSTANT => IPHONE4_COMPAT_ARGS]
		
		DIAGNOSTIC_ARGS = "--psnr --ssim"
		OPTIONAL_ENHANCEMENTS = "--non-deterministic"
		
		ANIME_TUNE_ARGS = "--deblock 2:2 --psy-rd 0.3 --bframes 16 --b-pyramid none"
	end

	class EncodingJob
		attr_accessor :mediaFile, :avsFile, :outputFile, :encodingOptions
		
		def initialize(mediaFile, avsFile, outputFile, encodingOptions)
			@mediaFile = mediaFile
			@avsFile = avsFile
			@outputFile = outputFile
			@encodingOptions = encodingOptions #This should be an array of "EncodingConstants"
		end
		
		def getEncodingOptionsAsString
			options = ""
			@encodingOptions.each{|e|
				options << "#{e} " #That space is intentional
			}
			
			return options
		end
		
		def getBaseFileName
			return File.basename(@mediaFile, File.extname(@mediaFile))
		end
	end
	
	class AVSFile
		attr_accessor :mediaSource, :filters
		
		STANDARD_AVS_SCRIPT = "ffindex(x)\ny=directshowsource(x)\nffvideosource(x, fpsnum=24000, fpsden=1001)\ngradfun2db()\n"
		
		def initialize(mediaSource, filters)
			@mediaSource = mediaSource
			@filters = filters
		end
		
		def outputAvsFile(outputFileName)
			begin
				avsFile = File.open(outputFileName, 'w')
				
				script = "x = #{@mediaSource}\n#{STANDARD_AVS_SCRIPT}"
				
				@filters.each{|e|
					script << "#{e}\n"
				}
				
				avsFile.put(script)
			
			rescue
				return false
			ensure
				avsFile.close
			end
			
			return true
		end
	end	
end