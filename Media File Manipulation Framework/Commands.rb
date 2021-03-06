#This file is part of Auto Device Encoder.
#
#Auto Device Encoder is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Auto Device Encoder is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Auto Device Encoder.  If not, see <http://www.gnu.org/licenses/>.
require 'puremvc-ruby'
require 'fileutils'

#All Modules should probably go here
require './Constants'
require './InputModule'
require './MediaTaskObjects'
require './AudioEncoders'
require './MediaContainerTools'
require './Loggers'
require './MediaInfo'

module Commands
	#General Commands
	class PrintHelpCommand < SimpleCommand
		def execute(note)
			InputModule::InputParser.printHelp
		end
	end

	#Fail out commands
	class ExitCommand < SimpleCommand
		def execute(note)
			case note.name
			when Constants::Notifications::EXIT_SUCCESS
				exit(0)
			when Constants::Notifications::EXIT_FAILURE
				exit(1)
			end
		end
	end

	class OutputCopyLeftNotice < SimpleCommand
		def execute(note)
			puts("\n#{Constants::CopyLeftConstants::COPYLEFT_NOTICE}\n\n")
			$stdout.flush
		end
	end

	#Input Parsing State - Initialization is automatic, but we need to validate the program args
	class ValidateProgramArgsCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			facade.send_notification(Constants::Notifications::LOG_INFO, "Validating Program Arguments")
			programArgs = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY).programArgs
			
			validateFiles = isValidFiles(programArgs.files)
			validateDevice = isValidDevice(programArgs.device)
			validateQuality = isValidQuality(programArgs.quality)
			
			if  validateFiles &&  validateDevice && validateQuality then
				facade.send_notification(Constants::Notifications::LOG_INFO, "Arguments Validated. Moving to Discovery State")
			else
				facade.send_notification(Constants::Notifications::LOG_ERROR, "Invalid Arguments Passed")
				facade.send_notification(Constants::Notifications::PRINT_HELP)
				facade.send_notification(Constants::Notifications::EXIT_FAILURE)
			end
		end

		def isValidFiles(files)
			if files != nil && files.is_a?(Array) && files.size > 0 then
				return true
			end
			
			Facade.instance.send_notification(Constants::Notifications::LOG_ERROR, "No Files Passed")
			
			return false
		end

		def isValidDevice(device)
			if device == nil then
				Facade.instance.send_notification(Constants::Notifications::LOG_ERROR, "No device passed in")
				return false;
			end

			if device.is_a?(Array) then
				device.each{|i|
					if !Constants::DeviceConstants::DEVICE_VECTOR.include?(i) then
						Facade.instance.send_notification(Constants::Notifications::LOG_ERROR, "Unknown Device Passed (#{i})")
						return false
					end
				}
				return true
			end
			return false
		end

		def isValidQuality(quality)
			if quality == nil || Constants::ValidInputConstants::QUALITY_VECTOR.include?(quality) then
				return true
			end
			
			Facade.instance.send_notification(Constants::Notifications::LOG_ERROR, "Unknown Quality Passed (#{quality})")
			return false
		end
	end
	
	class LaunchEncodingCycleMacroCommand < MacroCommand
		def initialize_macro_command()
			add_sub_command(RetrieveAllMediaFilesCommand)
			add_sub_command(GenerateEncodingJobsCommand)
			add_sub_command(ExecuteAllEncodingJobsCommand)
		end
	end
	
	#Discovery state commands
	class RetrieveAllMediaFilesCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			files = programArgsProxy.programArgs.files
			blacklist = programArgsProxy.programArgs.blacklist

			facade.send_notification(Constants::Notifications::LOG_INFO, "Gathering Media Files")

			if files[0].casecmp(Constants::ValidInputConstants::ALL_FILES) == 0 then
				facade.send_notification(Constants::Notifications::LOG_INFO, "Processing All Media Files in Directory")
				cd = Dir.new('.')

				cd.each{|e|
					processFile(e, blacklist)
				}
			else
				files.each{|e|
					processFile(e, blacklist)
				}
			end
		end

		def processFile(file, blacklist)
			if MediaInfo::MediaInfoTools.isAMediaFile(file) && !blacklist.include?(file) then
				Facade.instance.send_notification(Constants::Notifications::LOG_INFO, "Adding File #{file}")
				mediaFile = MediaInfo::MediaInfoTools.getMediaInfo(file)

				mediaFileProxy = Facade.instance.retrieve_proxy(Constants::ProxyConstants::MEDIA_FILE_PROXY)

				mediaFileProxy.addMediaFile(mediaFile)
			end
		end
	end

#Generate Encoding Jobs
	class GenerateEncodingJobsCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			encodingJobsProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			mediaFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::MEDIA_FILE_PROXY)
			programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)

			#Retrieve encoding settings; defaults are already set and guaranteed to work
			device = programArgsProxy.programArgs.device
			audioTrackNumber = programArgsProxy.programArgs.audioTrack
			subtitleTrackNumber = programArgsProxy.programArgs.subtitleTrack
			quality = programArgsProxy.programArgs.quality
			avsCommands = programArgsProxy.programArgs.avsCommands
			postJobs = programArgsProxy.programArgs.postJobs
			ensure169 = programArgsProxy.programArgs.ensure169
			ensure720p = programArgsProxy.programArgs.ensure720p
			
			noMux = programArgsProxy.programArgs.noMultiplex
			noAudio = programArgsProxy.programArgs.noAudio
			noSubtitles = programArgsProxy.programArgs.noSubtitles
			
			hqAudio = programArgsProxy.programArgs.hqAudio

			facade.send_notification(Constants::Notifications::LOG_INFO, "Generating Encoding Jobs")
			
			#Cycle through each device
			device.each{|d|
				#Generate command array
				encodingOptions = Constants::EncodingConstants.STANDARD_ENCODING_PREFIX
				
				#Determine quality
				encodingOptions << Constants::EncodingConstants::ENCODING_QUALITY_HASH[quality]
				
				#Abstract way to get device args			
				encodingOptions << Constants::EncodingConstants::DEVICE_COMPAT_HASH[d]
				
				#Go through each media file
				mediaFileProxy.mediaFiles.each{|e|
					outputName = generateDefaultOutputName(e.getBaseName, d)
					facade.send_notification(Constants::Notifications::LOG_INFO, "Creating Encoding Job for #{e.file} for #{d} at #{quality} quality. Output file: #{outputName}")
					avsFile = MediaTaskObjects::AVSFile.new(e.file, avsCommands)
					encodingJob = MediaTaskObjects::EncodingJob.new(e, avsFile, outputName, noMux, noAudio, noSubtitles, encodingOptions)
					
					encodingJob.hqAudio = hqAudio
					
					if audioTrackNumber != nil then
						encodingJob.audioTrack = audioTrackNumber.to_i
					end
					
					if subtitleTrackNumber != nil then
						encodingJob.subtitleTrack = subtitleTrackNumber.to_i
					end

					encodingJob.ensure169 = ensure169
					encodingJob.ensure720p = ensure720p
					
					encodingJobsProxy.addEncodingJob(encodingJob)
				}
			}
		end

		def generateDefaultOutputName(file, device)
			return file + Constants::DeviceConstants::DEFAULT_NAME_BY_DEVICE[device] + ".mp4"
		end
	end

	#Encoding Cycle Super-State
	class ExecuteAllEncodingJobsCommand < SimpleCommand
		def execute(note)
		facade = Facade.instance
		encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
		facade.send_notification(Constants::Notifications::LOG_INFO, "Executing All Encoding Jobs")

		encodingJobProxy.encodingJobs.each{|e|
			if !e.noAudio then
				facade.send_notification(Constants::Notifications::EXTRACT_AUDIO_TRACK, e)
			end
			
			if !e.noSubtitles then
				facade.send_notification(Constants::Notifications::EXTRACT_SUBTITLE_TRACK, e)
			end
			
			facade.send_notification(Constants::Notifications::GENERATE_AVISYNTH_FILE, e)
			facade.send_notification(Constants::Notifications::ENCODE_FILE, e)
			
			if !e.noMux then
				facade.send_notification(Constants::Notifications::MULTIPLEX_FILE, e)
			end
			
			facade.send_notification(Constants::Notifications::CLEANUP_FILES, e)
			facade.send_notification(Constants::Notifications::MOVE_FINISHED_FILE, e.outputFile)
		}
		end
	end

	class ExtractAudioTrackCommand < SimpleCommand
		def getPostJobsForAudioTrack(track)
			postCommand = []
			case track.trackFormat
				when Constants::TrackFormat::AAC
					return postCommand
				when Constants::TrackFormat::FLAC
					postCommand << :DECODE_FLAC
					postCommand << :ENCODE_AAC
				when Constants::TrackFormat::WAV
					postCommand << :ENCODE_AAC
				else
					postCommand << :DECODE_FFMPEG
					postCommand << :ENCODE_AAC
			end

			return postCommand
		end
		
		def extractAudioTrackAndEncode(encodingJob)
			facade = Facade.instance
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
			audioTrack = encodingJob.audioTrack
			programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			mediaFile = encodingJob.mediaFile
			postCommands = []
			
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Extracting Audio Track for #{realFile}")
			
			if audioTrack != nil then
				#First see if there's a particular audio track the user wants us to extract
				postCommands = getPostJobsForAudioTrack(mediaFile.getTrack(audioTrack))
			else
				#Otherwise, cycle through tracks to see if any of them are audio tracks
				case mediaFile.mediaContainerType
				when Constants::MediaContainers::MKV, Constants::MediaContainers::MP4
					audioTracks = mediaFile.getAudioTracks()
					
					chosenAudioTrack = nil
					if programArgsProxy.programArgs.ensureJap then
						facade.send_notification(Constants::Notifications::LOG_INFO, "Attempting to use Japanese track")
						chosenAudioTrack = chooseBestAudioTrack(audioTracks, "Japanese")
						
						if chosenAudioTrack == nil then
							facade.send_notification(Constants::Notifications::LOG_INFO, "Did not find suitable Japanese audio track. Defaulting to first available audio track.")
							chosenAudioTrack = chooseBestAudioTrack(audioTracks)
						end
						
					else
						chosenAudioTrack = chooseBestAudioTrack(audioTracks)
					end
					
					if chosenAudioTrack != nil then
						if chosenAudioTrack.language != nil then
							facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{chosenAudioTrack.trackFormat} Audio for #{realFile} with #{chosenAudioTrack.language}")
						else
							facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{chosenAudioTrack.trackFormat} Audio for #{realFile}")
						end
						
						audioTrack = chosenAudioTrack.trackID
						postCommands = getPostJobsForAudioTrack(chosenAudioTrack)
					else
						facade.send_notification(Constants::Notifications::LOG_INFO, "Did not find suitable. Defaulting to first available audio track.")
					end
				end
			end
			
			#Make sure we actually got a track and that we're not in "no-mux" mode
			if audioTrack != nil then 
				#Extract Track, whatever it is
				facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Track (Audio) ##{audioTrack} for #{realFile}")
				extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(mediaFile, audioTrack)

				system(extractionCommand[0])

				previousFile = extractionCommand[1]

				postCommands.each{|comm|
					case comm
					when :DECODE_FLAC
						postComm = AudioEncoders::FlacDecoder.generateDecodeFlacToWavCommand(previousFile)

						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Flac file
						
						facade.send_notification(Constants::Notifications::LOG_INFO, "Decoding FLAC to WAV")
						system(postComm[0])

						previousFile = postComm[1]
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Wav File
						
					when :DECODE_FFMPEG
						postComm = AudioEncoders::FFMpegDecoder.generateDecodeAudioToWav(previousFile)
						
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add generic audio file
						
						facade.send_notification(Constants::Notifications::LOG_INFO, "Decoding Audio Track With FFMPEG")
						system(postComm[0])
						
						previousFile = postComm[1]
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Wav File
						
					when :ENCODE_AAC
						#Check to see if the track we selected is actually 5.1; that way we can set the HQ audio flag
						useHqAudio = mediaFile.getTrack(audioTrack).channels > 2 || encodingJob.hqAudio
						
						facade.send_notification(Constants::Notifications::LOG_INFO, "Encoding Audio File With AAC")
						
						if(useHqAudio)
							facade.send_notification(Constants::Notifications::LOG_INFO, "Using HQ Audio")
						end
						
						postComm = AudioEncoders::AacEncoder.generateEncodeWavToAacCommand(previousFile, useHqAudio)
						system(postComm[0])

						previousFile = postComm[1]
					end
				}
				
				#Assign the AAC file to the EncodingJobProxy
				encodingJobProxy.addAudioTrackFile(encodingJob, previousFile)
				tempFileProxy.addTemporaryFile(encodingJob, previousFile) #Add AAC file to temp file proxy
			end
		end
		
		def generateAudioAVSScript(mediaFileName, trackID, outputFile)
			# In the AVS Script, we have to subtract the trackID by 1 because it uses a 0-based index, while everyone else uses a 1-based index. Fuck this stupid shit
			scriptText = "x = \"#{mediaFileName}\"\nffindex(x)\naudiodub(ffvideosource(x), ffaudiosource(x, track=#{trackID - 1}))"
			
			avsFile = File.open(outputFile, 'w')
			
			avsFile.puts(scriptText)
			
			avsFile.close
		end
		
		def encodeMediaAudioDirectly(encodingJob)
			facade = Facade.instance
			audioTrack = encodingJob.audioTrack
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Encoding Audio Directly from #{realFile}")
			
			audioTracks = mediaFile.getAudioTracks()
			
			chosenAudioTrack = nil
			if programArgsProxy.programArgs.ensureJap then
				facade.send_notification(Constants::Notifications::LOG_INFO, "Attempting to use Japanese track")
				chosenAudioTrack = chooseBestAudioTrack(audioTracks, "Japanese")
			else
				chosenAudioTrack = chooseBestAudioTrack(audioTracks)
			end
			
			#Generate avs script
			tempOutputAVS = "temp_audio_#{realFile}.avs"
			generateAudioAVSScript(realFile, chosenAudioTrack.trackID, tempOutputAVS) 
			
			#Execute the AVS2Pipe
			useHqAudio = chosenAudioTrack.channels > 2 || encodingJob.hqAudio
			outputAudioFile = File.basename(realFile, File.extname(realFile)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::AAC]
			bitrate = useHqAudio ? 256000: 96000
			command = "avs2pipe_vs.exe audio \"#{tempOutputAVS}\" | #{Constants::AudioExecutables::NERO_AAC} -br #{bitrate} -if - -of \"#{outputAudioFile}\""
			
			system(command) 
			encodingJobProxy.addAudioTrackFile(encodingJob, outputAudioFile)
			tempFileProxy.addTemporaryFile(encodingJob, outputAudioFile) 
			tempFileProxy.addTemporaryFile(encodingJob, tempOutputAVS) 
		end
			
		#Order by: Japanese > nil > Everything else
		#Then order by track type: FLAC > WAV > AAC > Everything else
		def chooseBestAudioTrack(audioTracks, language = nil)
			if audioTracks == nil || audioTracks.empty? then
				return nil
			end
			chosenTracks = []
			
			if language != nil then
				#Cycle through tracks and just pick out the ones that have a nil language or japanese language
				audioTracks.each{|t|
					if t.language == nil || t.language.casecmp(language) == 0 then
						chosenTracks << t
					end
				}
				
				chosenTracks.sort!{|a, b|
					if a.language == nil then
						if b.language == nil then
							0 #both are nil, equal
						else
							1 #"b" has the language we want, but "a" doesn't, therefore "a" goes to the back of the line
						end
					else
						if b.language == nil then
							-1 #"a" has the language we want, but "b" doesn't
						else
							0 #"a" and "b" have the language we want; equal
						end
					end
				}
			else
				chosenTracks = Array.new(audioTracks)
			end
			
			if chosenTracks.empty? then
				return nil
			end
			
			#Cycle through and choose the best track format
			chosenTrack = nil
			chosenTracks.each{|e|
				case e.trackFormat
					when Constants::TrackFormat::FLAC #Prefer FLAC
						chosenTrack = e
						break
					when Constants::TrackFormat::WAV #Then prefer WAV
						chosenTrack = e
						break
					when Constants::TrackFormat::AAC #Then prefer AAC
						chosenTrack = e
						break
					else
						chosenTrack = e
				end
			}
			return chosenTrack
		end
		
		def execute(note)
			facade = Facade.instance
			programArgsProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			
			if programArgsProxy.programArgs.encodeAudioDirectly then
				encodeMediaAudioDirectly(note.body)
			else
				extractAudioTrackAndEncode(note.body)
			end
		end
	end

	class ExtractSubtitleTrackCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
			subtitleTrackNumber = encodingJob.subtitleTrack
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Extracting Subtitle Track for #{realFile}")
			
			if subtitleTrackNumber == nil && mediaFile.mediaContainerType == Constants::MediaContainers::MKV then
				#See if the user wants to extract a particular track. If they do, then
				#we don't have to cycle through the tracks

				#Also, we can't extract subtitle tracks from any other type of media format
				mediaFile.tracks.each{|e|
					case e.trackFormat
					when Constants::TrackFormat::ASS
						facade.send_notification(Constants::Notifications::LOG_INFO, "Found ASS Track for #{realFile}")
						subtitleTrackNumber = e.trackID
						break
						
					when Constants::TrackFormat::SSA, Constants::TrackFormat::UTF_EIGHT
						facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{e.trackFormat} Track for #{realFile}")
						subtitleTrackNumber = e.trackID
						break

					when Constants::TrackFormat::VOB_SUB #this is a weird format
						facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{e.trackFormat} Track for #{realFile}")
						subtitleTrackNumber = e.trackID
						break
					end
				}
			end

			if subtitleTrackNumber != nil then
				#Check to see if the subtitle track actually was found
				facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Track (Subtitles) ##{subtitleTrackNumber} for #{realFile}")
				extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(mediaFile, subtitleTrackNumber)
				subtitleTrackObject = mediaFile.getTrack(subtitleTrackNumber)
				system(extractionCommand[0])

				#OK, so VOB_SUB is a weird fucking format. Basically, when you tell mkvextract.exe to extract the VOB_SUB track, you tell it to extract the
				#*.idx file instead of the *.sub file. When you do, mkvextract will extract both files. Now, here's the thing, you don't pass the 
				#*.idx file to avisynth filter. You pass the *.sub file to the avisynth filter, so you have to save the *.sub file in the EncodingJobProxy. 
				#It's very weird and special cased for VOB_SUB
				if subtitleTrackObject.trackFormat == Constants::TrackFormat::VOB_SUB then
					#Add the *.idx file
					tempFileProxy.addTemporaryFile(encodingJob, extractionCommand[1])
					
					#Formulate the *.sub file
					subFile = File.basename(extractionCommand[1], Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::VOB_SUB]) + ".sub"
					
					facade.send_notification(Constants::Notifications::LOG_INFO, "Special casing for VOB_SUB. Adding #{subFile} to encoding job proxy and temp file proxy")
					encodingJobProxy.addSubtitleTrackFile(encodingJob, subFile)
					tempFileProxy.addTemporaryFile(encodingJob, subFile)
				else
					encodingJobProxy.addSubtitleTrackFile(encodingJob, extractionCommand[1])
					tempFileProxy.addTemporaryFile(encodingJob, extractionCommand[1])
				end
			end
		end
	end

	class GenerateAvisynthFileCommand < SimpleCommand
		class Resolution
			attr_accessor :width, :height
			
			def initialize(width, height)
				@width = width
				@height = height
			end
		end
		
		class ResolutionResolver
			attr_accessor :ensure_720p, :ensure_16_9, :resolution
			
			def initialize(ensure_720p, ensure_16_9, resolution)
				@ensure_720p = ensure_720p
				@ensure_16_9 = ensure_16_9
				@resolution = resolution
			end
			
			def self.gcd(a, b)
				if !(a.is_a? Integer) || !(b.is_a? Integer) then
					raise "Invalid input. GCD can only work on Integers"
				end
				
				if a == b then
					return a
				end
				
				larger = a
				smaller = b
				
				if a < b then
					larger = b
					smaller = a
				end
				
				quotient = larger / smaller
				remainder = larger % smaller
				
				if remainder == 0 then
					return smaller
				end
				
				if remainder == 1 then
					return 1
				end
				
				return gcd(smaller, remainder)
			end
			
			def self.isEven?(number)
				number % 2 == 0
			end
			
			def self.isOdd?(number)
				isEven?(number) == false
			end
			
			def self.makeDivisibleByN(number, n)
				number + (number % n)
			end
			
			def self.calculateAspectMultiplier(oldResolution, aspectWidth, aspectHeight)
				widthCoefficient = oldResolution.width / aspectWidth
				heightCoefficient = oldResolution.height / aspectHeight
				
				widthCoefficientBy4 = makeDivisibleByN(widthCoefficient, 4)
				heightCoefficientBy4 = makeDivisibleByN(heightCoefficient, 4)
				
				widthCoefficientBy4 < heightCoefficientBy4 ? widthCoefficientBy4 : heightCoefficientBy4
			end
			
			def self.enforce169(oldResolution)
				aspectMultiplier = calculateAspectMultiplier(oldResolution, 16, 9)
				return Resolution.new(16 * aspectMultiplier, 9 * aspectMultiplier)
			end
			
			def self.enforce720p(oldResolution)
				if oldResolution.height <= 720 then
					return oldResolution
				end
			
				aspectCoefficient = gcd(oldResolution.width, oldResolution.height)
				widthCoPrime = oldResolution.width / aspectCoefficient
				heightCoPrime = oldResolution.height / aspectCoefficient
				
				closestCoefficient = 720 / heightCoPrime
				
				return Resolution.new(closestCoefficient * widthCoPrime, closestCoefficient * heightCoPrime)
			end
			
			def getFinalResolution
				resolvedResolution = @resolution
				
				if @ensure_16_9 then
					resolvedResolution = ResolutionResolver::enforce169(resolvedResolution)
				end
				
				if @ensure_720p then
					resolvedResolution = ResolutionResolver::enforce720p(resolvedResolution)
				end
				
				return resolvedResolution
			end
		end
	
		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			avsFile = encodingJob.avsFile
			
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)

			outputFile = mediaFile.getBaseName + MediaTaskObjects::AVSFile::AVS_EXTENSION
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Avisynth File Generation for #{realFile}")
			
			#Get subtitle track
			encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			subtitleTrackFile = encodingJobProxy.getSubtitleTrackFile(encodingJob)

			if subtitleTrackFile != nil then
				extension = File.extname(subtitleTrackFile)
				if extension == ".sub" then
					avsFile.addPreFilter(Constants::AvisynthFilterConstants::VOBSUB_FILTER + "(\"#{subtitleTrackFile}\")")
				else
					avsFile.addPreFilter(Constants::AvisynthFilterConstants::TEXTSUB_FILTER + "(\"#{subtitleTrackFile}\")")
				end
				
				facade.send_notification(Constants::Notifications::LOG_INFO, "Adding Textsub Prefilter for #{subtitleTrackFile}")
			end
			
			videoTrack = mediaFile.getVideoTracks[0]
			originalResolution = Resolution.new(videoTrack.width, videoTrack.height)
			resolutionResolver = ResolutionResolver.new(encodingJob.ensure720p, encodingJob.ensure169, originalResolution)
			
			resolvedResolution = resolutionResolver.getFinalResolution()
			
			if resolvedResolution.width != originalResolution.width || resolvedResolution.height != originalResolution.height
				avsFile.addPostFilter("#{Constants::AvisynthFilterConstants::LANCZOS_RESIZE}(#{resolvedResolution.width}, #{resolvedResolution.height})")
				facade.send_notification(Constants::Notifications::LOG_INFO, "Resizing video to ensure 16:9 and/or ensure 720p. Resizing from #{videoTrack.width} / #{videoTrack.height} to #{resolvedResolution.width} / #{resolvedResolution.height}")
			end
			
			avsFile.outputAvsFile(outputFile)
			facade.send_notification(Constants::Notifications::LOG_INFO, "Output Avisynth File for #{realFile}")
			facade.retrieve_proxy(Constants::ProxyConstants::AVISYNTH_FILE_PROXY).addAvisynthFile(encodingJob, outputFile)
			tempFileProxy.addTemporaryFile(encodingJob, outputFile)
		end
	end

	class EncodeFileCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			#We use the output file because we don't know the device and if we flag the job as "noMux", we'll end up overriding our previous bytefile
			#when we're encoding for multiple devices
			outputFile = encodingJob.outputFile
			byteFile = File.basename(outputFile, File.extname(outputFile)) + ".264"

			encodedFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODED_FILE_PROXY)
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Encoding #{realFile}")

			#form command
			command = Constants::EncodingConstants::X264
			encodingJob.encodingOptions.each{|e|
				command = command + " " + e
			}
			
			avsFile = facade.retrieve_proxy(Constants::ProxyConstants::AVISYNTH_FILE_PROXY).getAvisynthFile(encodingJob)

			command = command + " " + Constants::EncodingConstants::OUTPUT_ARG + " \"#{byteFile}\" \"#{avsFile}\""

			facade.send_notification(Constants::Notifications::LOG_INFO, "Executing encoding command: #{command}")
			system(command)

			#Add file to temporaryFile proxy only if noMux = false and noAudio = false
			if !encodingJob.noMux && !encodingJob.noAudio then
				tempFileProxy.addTemporaryFile(encodingJob, byteFile)
			end
			
			#Add the file to the encoded file proxy
			encodedFileProxy.addEncodedFile(encodingJob, byteFile)
			
			#add .ffindex file
			tempFileProxy.addTemporaryFile(encodingJob, mediaFile.file + ".ffindex")
		end
	end
	
	#This command is slightly smarter than the others, and does checks against the encoding job object. This is just meant to help out
	#with allowing the ExecutionCommand to skip whole commands, as they do not check against the encodingJob object
	class MultiplexFileCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			encodedFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODED_FILE_PROXY)
			encodingJobsProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)

			encodedByteFile = encodedFileProxy.getEncodedFile(encodingJob)
			audioFile = encodingJobsProxy.getAudioTrackFile(encodingJob)

			#Multiplex only if we're suppose to and if there's an audio file to multiplex. Otherwise
			#skip multiplexing if there's only a raw 264 byte stream
			if !encodingJob.noMux && encodedByteFile != nil && audioFile != nil then
				facade.send_notification(Constants::Notifications::LOG_INFO, "Multiplexing files \"#{encodedByteFile}\" and \"#{audioFile}\" to form \"#{encodingJob.outputFile}\"")
				
				multiplexingCommands = []
				multiplexingCommands << MediaContainerTools::ContainerTools.generateMultiplexToMP4Command(encodedByteFile, encodingJob.outputFile)
				multiplexingCommands << MediaContainerTools::ContainerTools.generateMultiplexToMP4Command(audioFile, encodingJob.outputFile)

				multiplexingCommands.each{|e|
					system(e)
				}
			end
		end
	end

	class CleanUpEncodingJobCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			facade.send_notification(Constants::Notifications::LOG_INFO, "Cleaning Up Files For #{encodingJob.mediaFile.file}")
			tempFiles = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY).getTemporaryFiles(encodingJob)

			tempFiles.each{|e|
				facade.send_notification(Constants::Notifications::LOG_INFO, "Deleting File #{e}")
				File.delete("#{e}")
			}
		end
	end
	
	class MoveFilesToFinishedFolderCommand < SimpleCommand
		def execute(note)
			if !Dir.exists?("Finished") then
			facade.send_notification(Constants::Notifications::LOG_INFO, "Creating Finished Directory")
				Dir.mkdir("Finished")
			end
			
			facade.send_notification(Constants::Notifications::LOG_INFO, "Moving file #{note.body} to Finished directory")
			FileUtils.mv(note.body, "Finished#{File::SEPARATOR}#{note.body}")
		end
	end
end