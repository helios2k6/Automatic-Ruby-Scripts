module Constants
	class ProxyConstants
		ENCODING_JOBS_PROXY = "ENCODING_JOBS_PROXY"
		LOGGER_PROXY = "LOGGER_PROXY"
		PROGRAM_ARGS_PROXY = "PROGRAM_ARGS_PROXY"
		EXECUTOR_PROXY = "EXECUTOR_PROXY"
		SCREEN_PROXY = "SCREEN_PROXY"
		MEDIA_FILE_PROXY = "MEDIA_FILE_PROXY"
		TICKET_MASTER_PROXY = "TICKET_MASTER_PROXY"
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

    DEVICE_VECTOR = [PS3_CONSTANT, IPHONE4_CONSTANT]
  end
  
  class Notifications
    #INFO NOTIFICATIONS
    LOG_INFO = "LOG_INFO"
    LOG_ERROR = "LOG_ERROR"
    
    PRINT_HELP = "PRINT_HELP"
    
		UPDATE_SCREEN = "UPDATE_SCREEN" #Used to instruct the screen to refresh with some sort of message
		EXECUTE_EXTERNAL_COMMAND = "EXECUTE_EXTERNAL_COMMAND" #Used to instruct the execution of a command
		
    EXTERNAL_COMMAND_NOT_EXECUTED = "EXTERNAL_COMMAND_NOT_EXECUTED"
    
		EXTERNAL_COMMAND_EXECUTED = "EXTERNAL_COMMAND_EXECUTED" #Used to signal that a command has been executed
    EXTERNAL_COMMAND_FINISHED_EXECUTING = "EXTERNAL_COMMAND_FINISHED_EXECUTING" #Used to signal that a command has finished executing
    
    #Command Notifications
    
    #Program Failure
    EXIT_SUCCESS = "EXIT_SUCCESS"
    EXIT_FAILURE = "EXIT_FAILURE"
    
    #Encoding Cycle Failures
    AUDIO_EXTRACTION_FAILURE = "AUDIO_EXTRACTION_FAILURE"
    SUBTITLE_EXTRACTION_FAILURE = "SUBTITLE_EXTRACTION_FAILURE"
    GENERATION_FAILURE = "GENERATION_FAILURE"
    ENCODE_FAILURE = "ENCODE_FAILURE"
    MULTIPLEXING_FAILURE = "MULTIPLEXING_FAILURE"
    
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
  end
  
  class InputConstants    
    #Program Version
    VERSION = "2012.2.1"
    PROG_HELP_HEADER = 	"Auto Device Encoder #{VERSION}\nAuthor: Andrew Johnson\n\nUsage: ruby <this script> [options]\n\nOptions:\n\n"

    FILE_ARG = "--files"
    FILE_ARG_HELP_STRING =	"\t#{FILE_ARG} <file 1>[ <file 2> <file 3>...]\n\t\tThe name(s) of the media files you want to encode\n\t\tAllowed to put \"#{ValidInputConstants::ALL_FILES}\" to specify all media files in current dir\n\n"

    #Special
    DEVICE_ARG = "--device"
    DEVICE_ARG_HELP_STRING =	"\t#{DEVICE_ARG} <string>\n\t\tSpecifies the device to encode for\n\t\tValid inputs: ps3, iphone4\n\n"

    QUALITY_ARG = "--quality"
    QUALITY_ARG_HELP_STRING = "\t#{QUALITY_ARG} <string>\n\t\tSpecifies the quality level for the encode\n\t\tValid inputs: low, medium, high, extreme"

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
    POST_ENCODING_ARG_HELP_STRING = "\t#{POST_ENCODING_ARG} <command 1>;args[ <command 2>;args]"

    PROG_ARG_VECTOR = [FILE_ARG, DEVICE_ARG, QUALITY_ARG, AVS_ADD_ARG, NO_MUX_ARG, HELP_ARG, FORCE_AUDIO_TRACK, FORCE_SUBTITLE_TRACK, BLACKLIST_ARG, POST_ENCODING_ARG]

    PROG_ARG_HELP_HASH = {
      FILE_ARG => FILE_ARG_HELP_STRING,
      BLACKLIST_ARG => BLACKLIST_ARG_HELP_STRING,
      DEVICE_ARG => DEVICE_ARG_HELP_STRING,
      QUALITY_ARG => QUALITY_ARG_HELP_STRING,
      AVS_ADD_ARG => AVS_ADD_ARG_HELP_STRING,
      NO_MUX_ARG => NO_MUX_ARG_HELP_STRING,
      FORCE_AUDIO_TRACK => FORCE_AUDIO_TRACK_HELP_STRING,
      FORCE_SUBTITLE_TRACK => FORCE_SUBTITLE_TRACK_HELP_STRING,
      POST_ENCODING_ARG => POST_ENCODING_ARG_HELP_STRING
    }

    PROG_ARG_DEFAULTS_HASH = {
      BLACKLIST_ARG => [],
      DEVICE_ARG => DeviceConstants::IPHONE4_CONSTANT,
      QUALITY_ARG => ValidInputConstants::MEDIUM_QUALITY,
      AVS_ADD_ARG => [],
      NO_MUX_ARG => false,
      POST_ENCODING_ARG => []
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
    WAV = "Wave"
		
		ASS = "ASS"
    SSA = "SSA"
		UTF_EIGHT = "UTF-8"
		
		TRACK_FORMAT_VECTOR = [AVC, VC_ONE, AAC, FLAC, AC3, VORBIS, ASS, UTF_EIGHT, WAV]
		
    AUDIO_FORMAT_VECTOR = [AAC, FLAC, AC3, VORBIS, WAV]
    VIDEO_FORMAT_VECTOR = [AVC, VC_ONE]
    SUBTITLE_FORMAT_VECTOR = [ASS, SSA, UTF_EIGHT]
    
		EXTENSION_HASH = {AVC => ".264", AAC => ".aac", FLAC => ".flac", AC3 => ".ac3", VORBIS => ".ogg", ASS => ".ass", SSA => ".ssa", UTF_EIGHT => ".srt", WAV => ".wav"}
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

    QUALITY_LOW = "--crf 24"

    QUALITY_MEDIUM = "--crf 22 --subme 8"

    QUALITY_HIGH = "--crf 20 --subme 9"

    QUALITY_EXTREME = "--crf 18 --subme 10 --trellis 2"

    PS3_COMPAT_ARGS = "--level 4.2 --profile high --aud --sar 1:1 --vbv-maxrate 31250 --vbv-bufsize 31250"
    IPHONE4_COMPAT_ARGS = "--level 3.1 --profile main --sar 1:1"

    DEVICE_COMPAT_HASH= {DeviceConstants::PS3_CONSTANT => PS3_COMPAT_ARGS, DeviceConstants::IPHONE4_CONSTANT => IPHONE4_COMPAT_ARGS}

    DIAGNOSTIC_ARGS = "--psnr --ssim"
    OPTIONAL_ENHANCEMENTS = "--non-deterministic"

    OUTPUT_ARG = "--output"

    ANIME_TUNE_ARGS = "--deblock 2:2 --psy-rd 0.3 --bframes 16 --b-pyramid none"
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
  
  class ScreenCommand
    PRINT_SAME_LINE = "PRINT_SAME_LINE"
    PRINT_NEW_LINE = "PRINT_NEW_LINE"
    KILL_SCREEN = "KILL_SCREEN" #this automatically gives us a new-line
    
    COMMAND_TO_CHARACTER_HASH = {PRINT_SAME_LINE => "\r", PRINT_NEW_LINE => "\n", KILL_SCREEN => "\n"}
  end
end