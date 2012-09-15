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

module Constants
	class ProgramName
		PROGRAM_NAME = "Auto Device Encoder"
		VERSION = "2012.2.4"
	end

	class CopyLeftConstants
		COPYLEFT_NOTICE = "#{ProgramName::PROGRAM_NAME}\nCopyright (C) 2012 Andrew Johnson\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions."
	end

	class AudioExecutables
		FLAC = "flac.exe"
		OGG_DECODER = "oggdec.exe"
		NERO_AAC = "neroAacEnc.exe"
		FFMPEG = "ffmpeg.exe"
	end

	class ProxyConstants
		ENCODING_JOBS_PROXY = "ENCODING_JOBS_PROXY"
		LOGGER_PROXY = "LOGGER_PROXY"
		PROGRAM_ARGS_PROXY = "PROGRAM_ARGS_PROXY"
		MEDIA_FILE_PROXY = "MEDIA_FILE_PROXY"
		ENCODED_FILE_PROXY = "ENCODED_FILE_PROXY"
		AVISYNTH_FILE_PROXY = "AVISYNTH_FILE_PROXY"
		TEMPORARY_FILES_PROXY = "TEMPORARY_FILES_PROXY"
	end

	class MediatorConstants
		SCREEN_MEDIATOR = "SCREEN_MEDIATOR"
		LOGGER_MEDIATOR = "LOGGER_MEDIATOR"
	end

	class DeviceConstants
		PS3_CONSTANT = "ps3"
		IPHONE4_CONSTANT = "iphone4"
		IPAD_3_CONSTANT = "ipad3"

		DEVICE_VECTOR = [PS3_CONSTANT, IPHONE4_CONSTANT, IPAD_3_CONSTANT]
		
		DEFAULT_NAME_BY_DEVICE = {PS3_CONSTANT => "_PS3", IPHONE4_CONSTANT => "_iPhone4", IPAD_3_CONSTANT => "_iPad3"}
	end

	class Notifications
		#INFO NOTIFICATIONS
		LOG_INFO = "LOG_INFO"
		LOG_ERROR = "LOG_ERROR"

		PRINT_HELP = "PRINT_HELP"

		#Copyleft Command
		OUTPUT_COPYLEFT = "OUTPUT_COPYLEFT"

		#Program Failure
		EXIT_SUCCESS = "EXIT_SUCCESS"
		EXIT_FAILURE = "EXIT_FAILURE"

		#Encoding Cycle Failures
		AUDIO_EXTRACTION_FAILURE = "AUDIO_EXTRACTION_FAILURE"
		SUBTITLE_EXTRACTION_FAILURE = "SUBTITLE_EXTRACTION_FAILURE"
		GENERATION_FAILURE = "GENERATION_FAILURE"
		ENCODE_FAILURE = "ENCODE_FAILURE"
		MULTIPLEXING_FAILURE = "MULTIPLEXING_FAILURE"

		#Launch macro encoding cycle command
		LAUNCH_ENCODING_CYCLE_MACRO_COMMAND = "LAUNCH_ENCODING_CYCLE_MACRO_COMMAND"
		
		#INPUT PARSING STATE COMMANDS
		VALIDATE_PROGRAM_ARGS = "VALIDATE_PROGRAM_ARGS"

		#DISCOVERY STATE COMMANDS
		RETRIEVE_MEDIA_FILES = "RETRIEVE_MEDIA_FILES"
		GENERATE_ENCODING_JOBS = "GENERATE_ENCODING_JOBS"

		#ENCODING CYCLE SUPER-STATE
		EXECUTE_ALL_ENCODING_JOBS = "EXECUTE_ALL_ENCODING_JOBS"

		#EXTRACTION STATE
		EXTRACT_AUDIO_TRACK = "EXTRACT_AUDIO_TRACK"
		EXTRACT_SUBTITLE_TRACK = "EXTRACT_SUBTITLE_TRACK"

		#GENERATION STATE
		GENERATE_AVISYNTH_FILE = "GENERATE_AVISYNTH_FILE"

		#ENCODING STATE
		ENCODE_FILE = "ENCODE_FILE"

		#MULTIPLEX STATE
		MULTIPLEX_FILE = "MULTIPLEX_FILE"

		#CLEANUP STATE
		CLEANUP_FILES = "CLEANUP_FILES"

		#POST-ENCODING STATE
		EXECUTE_POST_ENCODING_COMMANDS = "EXECUTE_POST_ENCODING_COMMANDS"
	end

	class ValidInputConstants
		ALL_FILES = "all"

		LOW_QUALITY = "low"
		MEDIUM_QUALITY = "medium"
		HIGH_QUALITY = "high"
		EXTREME_QUALITY = "extreme"

		QUALITY_VECTOR = [LOW_QUALITY, MEDIUM_QUALITY, HIGH_QUALITY, EXTREME_QUALITY]
		
		ARGUMENT_PREFIX = "--"
	end

	class InputConstants    
		PROG_HELP_HEADER = 	"#{ProgramName::PROGRAM_NAME} #{ProgramName::VERSION}\nAuthor: Andrew Johnson\n\nUsage: ruby <this script> [options]\n\nOptions:\n\n"

		FILE_ARG = "--files"
		FILE_ARG_HELP_STRING =	"\t#{FILE_ARG} <file 1>[ <file 2> <file 3>...]\n\t\tThe name(s) of the media files you want to encode\n\t\tAllowed to put \"#{ValidInputConstants::ALL_FILES}\" to specify all media files in current dir\n\n"

		#Special
		DEVICE_ARG = "--device"
		DEVICE_ARG_HELP_STRING =	"\t#{DEVICE_ARG} <string>\n\t\tSpecifies the device to encode for\n\t\tValid inputs: ps3, iphone4, ipad3\n\n"

		QUALITY_ARG = "--quality"
		QUALITY_ARG_HELP_STRING = "\t#{QUALITY_ARG} <string>\n\t\tSpecifies the quality level for the encode\n\t\tValid inputs: low, medium, high, extreme\n\n"

		AVS_ADD_ARG = "--avs-add"
		AVS_ADD_ARG_HELP_STRING =	"\t#{AVS_ADD_ARG} <string 1>[ <string 2> <string 3>...]\n\t\tAdds extra lines into the avisynth file\n\n"

		NO_MUX_ARG = "--no-mux"
		NO_MUX_ARG_HELP_STRING =	"\t#{NO_MUX_ARG}\n\t\tDon't multiplex the raw video\n\n"

		HELP_ARG = "--help"
		HELP_ARG_HELP_STRING =	"\t#{HELP_ARG}\n\t\tPrint this help screen\n\n"

		FORCE_AUDIO_TRACK = "--audio-track"
		FORCE_AUDIO_TRACK_HELP_STRING =	"\t#{FORCE_AUDIO_TRACK}\n\t\tUse specified track for audio\n\n"

		FORCE_SUBTITLE_TRACK = "--subtitle-track"
		FORCE_SUBTITLE_TRACK_HELP_STRING =	"\t#{FORCE_SUBTITLE_TRACK}\n\t\tUse specified track for subtitle\n\n"

		BLACKLIST_ARG = "--blacklist"
		BLACKLIST_ARG_HELP_STRING =		"\t#{BLACKLIST_ARG} <file 1>[ <file 2> <file 3>...]\n\t\tThe name(s) of the files you want to explicitly blacklist\n\t\tCan be used in conjunction with a list of files that have been whitelisted\n\t\tThe blacklist takes precedence over the whitelist\n\n"

		POST_ENCODING_ARG = "--post-encoding (not implemented)"
		POST_ENCODING_ARG_HELP_STRING = "\t#{POST_ENCODING_ARG}\n\t\t<command 1>;args[ <command 2>;args]\n\n"
		
		NO_AUDIO_ARG = "--no-audio"
		NO_AUDIO_ARG_HELP_STRING = "\t#{NO_AUDIO_ARG}\n\t\tDon't extract or encode the audio track. Overrides \"#{FORCE_AUDIO_TRACK}\"\n\n"
		
		NO_SUBS_ARG = "--no-subtitles"
		NO_SUBS_ARG_HELP_STRING = "\t#{NO_SUBS_ARG}\n\t\tDon't hardcode any subtitles. Override \"#{FORCE_SUBTITLE_TRACK}\"\n\n"
		
		VERY_HIGH_QUALITY_AUDIO_ARG = "--hq-audio"
		VERY_HIGH_QUALITY_AUDIO_ARG_HELP_STRING = "\t#{VERY_HIGH_QUALITY_AUDIO_ARG}\n\t\tSet bitrate to 256k for all AAC encoded audio\n\n"
		
		PROG_ARG_VECTOR = [FILE_ARG, DEVICE_ARG, QUALITY_ARG, AVS_ADD_ARG, NO_MUX_ARG, HELP_ARG, FORCE_AUDIO_TRACK, FORCE_SUBTITLE_TRACK, BLACKLIST_ARG, POST_ENCODING_ARG, NO_SUBS_ARG, NO_AUDIO_ARG, VERY_HIGH_QUALITY_AUDIO_ARG]

		PROG_ARG_HELP_HASH = {
			FILE_ARG => FILE_ARG_HELP_STRING,
			BLACKLIST_ARG => BLACKLIST_ARG_HELP_STRING,
			DEVICE_ARG => DEVICE_ARG_HELP_STRING,
			QUALITY_ARG => QUALITY_ARG_HELP_STRING,
			AVS_ADD_ARG => AVS_ADD_ARG_HELP_STRING,
			NO_MUX_ARG => NO_MUX_ARG_HELP_STRING,
			NO_AUDIO_ARG => NO_AUDIO_ARG_HELP_STRING,
			NO_SUBS_ARG => NO_SUBS_ARG_HELP_STRING,
			FORCE_AUDIO_TRACK => FORCE_AUDIO_TRACK_HELP_STRING,
			FORCE_SUBTITLE_TRACK => FORCE_SUBTITLE_TRACK_HELP_STRING,
			POST_ENCODING_ARG => POST_ENCODING_ARG_HELP_STRING,
			VERY_HIGH_QUALITY_AUDIO_ARG => VERY_HIGH_QUALITY_AUDIO_ARG_HELP_STRING
		}
	end

	class ExtractionToolsConstant
		MKV_EXTRACT = "mkvextract.exe"
		MKV_MERGE = "mkvmerge.exe"
		MP4BOX = "mp4box.exe"
	end

	class TrackType
		GENERAL = "General" #This is special. Do not put this in the Track Type Vector
		VIDEO = "Video"
		AUDIO = "Audio"
		TEXT = "Text"

		TRACK_TYPE_VECTOR = [VIDEO, AUDIO, TEXT]
	end

	class TrackFormat
		AVC = "AVC"
		VC_ONE = "VC-1"

		AAC = "AAC"
		FLAC = "FLAC"
		AC3 = "AC-3"
		VORBIS = "Vorbis"
		MP3 = "MPEG Audio"
		WAV = "Wave"
		DTS = "DTS"

		ASS = "ASS"
		SSA = "SSA"
		UTF_EIGHT = "UTF-8"

		TRACK_FORMAT_VECTOR = [AVC, VC_ONE, AAC, FLAC, AC3, VORBIS, ASS, UTF_EIGHT, WAV, MP3, DTS]

		AUDIO_FORMAT_VECTOR = [AAC, FLAC, AC3, VORBIS, WAV, MP3, DTS]
		VIDEO_FORMAT_VECTOR = [AVC, VC_ONE]
		SUBTITLE_FORMAT_VECTOR = [ASS, SSA, UTF_EIGHT]

		EXTENSION_HASH = {AVC => ".264", AAC => ".aac", FLAC => ".flac", AC3 => ".ac3", VORBIS => ".ogg", ASS => ".ass", SSA => ".ssa", UTF_EIGHT => ".srt", WAV => ".wav", MP3 => ".mp3", DTS => ".dts"}
	end

	class MediaContainers
		MKV = "Matroska"
		MP4 = "MPEG-4"
		AVI = "AVI"  
		WMV = "Windows Media"

		CONTAINER_VECTOR = [MKV, MP4, AVI, WMV]

		EXTENSION_HASH = {MKV => ".mkv", MP4 => ".mp4", AVI => ".avi", WMV => ".wmv"}
	end

	class EncodingConstants
		X264 = "x264.exe"

		COLOR_MATRIX = "--colormatrix bt709"

		ANIME_TUNE_ARGS = "--deblock 2:2 --psy-rd 0.3 --bframes 16 --b-pyramid none"
		
		DIAGNOSTIC_ARGS = "--psnr --ssim"
		
		OPTIONAL_ENHANCEMENTS = "--non-deterministic"
		
		QUALITY_LOW = "--crf 24"

		QUALITY_MEDIUM = "--crf 22 --subme 8"

		QUALITY_HIGH = "--crf 20 --subme 9"

		QUALITY_EXTREME = "--crf 18 --subme 10 --trellis 2"

		PS3_COMPAT_ARGS = "--level 4.2 --profile high --aud --sar 1:1 --vbv-maxrate 31250 --vbv-bufsize 31250"
		
		IPHONE4_COMPAT_ARGS = "--level 3.1 --profile main --sar 1:1"
		
		IPAD_3_COMPAT_ARGS = "--level 4.1 --profile high --aud --sar 1:1"
		
		OUTPUT_ARG = "--output"
		
		def self.STANDARD_ENCODING_PREFIX #Have to return a brandnew array each time
			return [COLOR_MATRIX, ANIME_TUNE_ARGS, DIAGNOSTIC_ARGS, OPTIONAL_ENHANCEMENTS]
		end
		
		ENCODING_QUALITY_HASH = {
			ValidInputConstants::LOW_QUALITY => QUALITY_LOW,
			ValidInputConstants::MEDIUM_QUALITY => QUALITY_MEDIUM,
			ValidInputConstants::HIGH_QUALITY => QUALITY_HIGH,
			ValidInputConstants::EXTREME_QUALITY => QUALITY_EXTREME}
		
		DEVICE_COMPAT_HASH= {
			DeviceConstants::PS3_CONSTANT => PS3_COMPAT_ARGS, 
			DeviceConstants::IPHONE4_CONSTANT => IPHONE4_COMPAT_ARGS, 
			DeviceConstants::IPAD_3_CONSTANT => IPAD_3_COMPAT_ARGS}
	end

	class AvisynthFilterConstants
		FFINDEX = "ffindex"
		DIRECTSHOW_SOURCE = "directShowSource"
		FFVIDEO_SOURCE = "ffvideosource"
		TEXTSUB_FILTER = "textsub"
		GRADFUN_2_DB = "gradfun2db"
		LANCZOS_RESIZE = "lanczosResize"
		SPLINE_64_RESIZE = "spline64Resize"
	end
end