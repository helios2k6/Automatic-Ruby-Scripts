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
require 'PureMVC_Ruby'
require 'Thread'
require './Constants'

#All Modules should probably go here
require './InputModule'
require './MediaTaskObjects'
require './TicketMaster'
require './AudioEncoders'
require './MediaContainerTools'
require './ScreenMediators'
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

	class FireExternalExecutionCommand < SimpleCommand
		#Exepect note.body = command
		def execute(note)
			facade = Facade.instance
			facade.send_notification(Constants::Notifications::LOG_INFO, "Executing External Command #{note.body}")

			#Skip these steps for now and directly execute the command
			executorProxy = facade.retrieve_proxy(Constants::ProxyConstants::EXECUTOR_PROXY)

			executorProxy.submitCommand(note.body)
		end
	end

	class HandleExternalExecutionOutputCommand < SimpleCommand
		def execute(note) #Expect note.body = [command, stdout]
			facade = Facade.instance
			io = note.body[1]

			buffer = ""
			fixedLength = 100

			result = io.read(fixedLength, buffer)

			while result != nil 
				#print buffer
				facade.send_notification(Constants::Notifications::UPDATE_SCREEN, [Constants::ScreenCommand::PRINT_AS_IS, note.body[0], buffer])
				
				result = io.read(fixedLength, buffer)
			end

			#Wait for process to die
			Process.wait(io.pid)

			facade.send_notification(Constants::Notifications::UPDATE_SCREEN, [Constants::ScreenCommand::KILL_SCREEN, note.body[0]])
		end
	end

	class OutputCopyLeftNotice < SimpleCommand
		def execute(note)
			puts("\n\n#{Constants::CopyLeftConstants::COPYLEFT_NOTICE}\n\n")
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
				facade.send_notification(Constants::Notifications::RETRIEVE_MEDIA_FILES)
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

	#Discovery state commands
	class RetrieveAllMediaFilesCommand < SimpleCommand
		def execute(note)
			facade = Facade.instance
			mediaFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::PROGRAM_ARGS_PROXY)
			files = mediaFileProxy.programArgs.files
			blacklist = mediaFileProxy.programArgs.blacklist

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

			facade.send_notification(Constants::Notifications::GENERATE_ENCODING_JOBS)
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

					encodingJobsProxy.addEncodingJob(encodingJob)
				}
			}
			
			facade.send_notification(Constants::Notifications::EXECUTE_ALL_ENCODING_JOBS)

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
		ticketMasterProxy = facade.retrieve_proxy(Constants::ProxyConstants::TICKET_MASTER_PROXY)
		facade.send_notification(Constants::Notifications::LOG_INFO, "Executing All Encoding Jobs")

		threads = []

		encodingJobProxy.encodingJobs.each{|e|
			threads << Thread.new do
				ticketNumber = ticketMasterProxy.getTicket
				
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
				ticketMasterProxy.returnTicket(ticketNumber)
			end
		}

		#Join on threads
		threads.each{|t|
			t.join
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

		def execute(note)
			facade = Facade.instance
			encodingJob = note.body
			mediaFile = encodingJob.mediaFile
			realFile = mediaFile.file
			encodingJobProxy = facade.retrieve_proxy(Constants::ProxyConstants::ENCODING_JOBS_PROXY)
			tempFileProxy = facade.retrieve_proxy(Constants::ProxyConstants::TEMPORARY_FILES_PROXY)
			audioTrack = encodingJob.audioTrack
			postCommands = []
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Extracting Audio Track for #{realFile}")
			
			if audioTrack != nil then
				#First see if there's a particular audio track the user wants us to extract
				postCommands = getPostJobsForAudioTrack(mediaFile.getTrack(audioTrack))
			else
				#Otherwise, cycle through tracks to see if any of them are audio tracks
				case mediaFile.mediaContainerType
				when Constants::MediaContainers::MKV, Constants::MediaContainers::MP4
					mediaFile.tracks.each{|e|
						if e.trackType == Constants::TrackType::AUDIO then
							case e.trackFormat
								when Constants::TrackFormat::FLAC
									facade.send_notification(Constants::Notifications::LOG_INFO, "Found FLAC Audio for #{realFile}")
									audioTrack = e.trackID
									postCommands = getPostJobsForAudioTrack(e)
									break
								
								when Constants::TrackFormat::WAV
									facade.send_notification(Constants::Notifications::LOG_INFO, "Found WAV Audio for #{realFile}")
									audioTrack = e.trackID
									postCommands = getPostJobsForAudioTrack(e)
									break
									
								when Constants::TrackFormat::AAC
									facade.send_notification(Constants::Notifications::LOG_INFO, "Found AAC Audio for #{realFile}")
									audioTrack = e.trackID
									break
								else
									facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{e.trackFormat} Audio for #{realFile}")
									audioTrack = e.trackID
									postCommands = getPostJobsForAudioTrack(e)
							end
						end
					}
				end
			end
			
			#Make sure we actually got a track and that we're not in "no-mux" mode
			if audioTrack != nil then 
				#Extract Track, whatever it is
				facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Track (Audio) ##{audioTrack} for #{realFile}")
				extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(mediaFile, audioTrack)

				facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, extractionCommand[0])

				previousFile = extractionCommand[1]

				postCommands.each{|comm|
					case comm
					when :DECODE_FLAC
						postComm = AudioEncoders::FlacDecoder.generateDecodeFlacToWavCommand(previousFile)

						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Flac file

						facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

						previousFile = postComm[1]
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Wav File
						
					when :DECODE_FFMPEG
						postComm = AudioEncoders::FFMpegDecoder.generateDecodeAudioToWav(previousFile)
						
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add generic audio file
						
						facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])
						
						previousFile = postComm[1]
						tempFileProxy.addTemporaryFile(encodingJob, previousFile) # Add Wav File
						
					when :ENCODE_AAC						
						postComm = AudioEncoders::AacEncoder.generateEncodeWavToAacCommand(previousFile, encodingJob.hqAudio)
						facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, postComm[0])

						previousFile = postComm[1]
					end
				}
				
				#Assign the AAC file to the EncodingJobProxy
				encodingJobProxy.addAudioTrackFile(encodingJob, previousFile)
				tempFileProxy.addTemporaryFile(encodingJob, previousFile) #Add AAC file to temp file proxy
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
			subtitleTrack = encodingJob.subtitleTrack
			facade.send_notification(Constants::Notifications::LOG_INFO, "Begin Extracting Subtitle Track for #{realFile}")
			
			if subtitleTrack == nil && mediaFile.mediaContainerType == Constants::MediaContainers::MKV then
				#See if the user wants to extract a particular track. If they do, then
				#we don't have to cycle through the tracks

				#Also, we can't extract subtitle tracks from any other type of media format
				mediaFile.tracks.each{|e|
					case e.trackFormat
					when Constants::TrackFormat::ASS
						facade.send_notification(Constants::Notifications::LOG_INFO, "Found ASS Track for #{realFile}")
						subtitleTrack = e.trackID
						break
						
					when Constants::TrackFormat::SSA, Constants::TrackFormat::UTF_EIGHT
						facade.send_notification(Constants::Notifications::LOG_INFO, "Found #{e.trackFormat} Track for #{realFile}")
						subtitleTrack = e.trackID
					end
				}
			end

			if subtitleTrack != nil then
				#Check to see if the subtitle track actually was found
				facade.send_notification(Constants::Notifications::LOG_INFO, "Extracting Track (Subtitles) ##{subtitleTrack} for #{realFile}")
				extractionCommand = MediaContainerTools::ContainerTools.generateExtractTrackCommand(mediaFile, subtitleTrack)

				facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, extractionCommand[0])

				encodingJobProxy.addSubtitleTrackFile(encodingJob, extractionCommand[1])
				tempFileProxy.addTemporaryFile(encodingJob, extractionCommand[1])
			end
		end
	end

	class GenerateAvisynthFileCommand < SimpleCommand
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
			subtitleTrack = encodingJobProxy.getSubtitleTrackFile(encodingJob)

			if subtitleTrack != nil then
				avsFile.addPreFilter(Constants::AvisynthFilterConstants::TEXTSUB_FILTER + "(\"#{subtitleTrack}\")")
				facade.send_notification(Constants::Notifications::LOG_INFO, "Adding Textsub Prefilter for #{subtitleTrack}")
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

			facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, command)

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
					facade.send_notification(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, e)
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
end