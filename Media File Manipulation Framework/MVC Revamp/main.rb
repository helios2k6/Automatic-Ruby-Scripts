require 'PureMVC_Ruby'
require './AudioEncoders'
require './Commands'
require './Constants'
require './Executors'
require './InputModule'
require './Loggers'
require './MediaObjects'
require './MediaTaskObjects'
require './Notifications'
require './ScreenMediators'
require './ScreenObjects'
require './TicketMaster'

def main
  facade = Facade.instance
	#Initialize All Proxies
  facade.register_proxy(EncodingJobsProxy.new)
  facade.register_proxy(LoggerProxy.new)
  facade.register_proxy(ProgramArgsProxy.new(ARGV))
  facade.register_proxy(ExecuteProxy.new)
  facade.register_proxy(ScreenProxy.new)
  facade.register_proxy(MediaFileProxy.new)
  facade.register_proxy(TicketProxy.new(1))
  facade.register_proxy(EncodedFileProxy.new)
  facade.register_proxy(AvisynthFileProxy.new)
  facade.register_proxy(TemporaryFilesProxy.new)
	  
	#Initialize All Commands
  facade.register_command(Notifications::Notifications::PRINT_HELP, PrintHelpCommand.new)
  
  facade.register_command(Notifications::Notifications::EXECUTE_EXTERNAL_COMMAND, FireExternalExecutionCommand.new)
  facade.register_command(Notifications::Notifications::EXTERNAL_COMMAND_EXECUTED, HandleExternalExecutionOutputCommand.new)
  
  exitCommand = ExitCommand.new
  facade.register_command(Notifications::EXIT_SUCCESS, exitCommand)
  facade.register_command(Notifications::EXIT_FAILURE, exitCommand)
  
  facade.register_command(Notifications::VALIDATE_PROGRAM_ARGS, ValidateProgramArgsCommand.new)
  
  facade.register_command(Notifications::RETRIEVE_MEDIA_FILES, RetrieveAllMediaFilesCommand.new)
  facade.register_command(Notifications::GENERATE_ENCODING_JOBS, GenerateEncodingJobsCommand.new)
  
  facade.register_command(Notifications::EXECUTE_ALL_ENCODING_JOBS, ExecuteAllEncodingJobsCommand.new)
  
  facade.register_command(Notifications::EXTRACT_AUDIO_TRACK, ExtractAudioTrackCommand.new)
  facade.register_command(Notifications::EXTRACT_SUBTITLE_TRACK, ExtractSubtitleTrackCommand.new)
  
  facade.register_command(Notifications::GENERATE_AVISYNTH_FILE, GenerateAvisynthFileCommand.new)
  
  facade.register_command(Notifications::ENCODE_FILE, EncodeFileCommand.new)
  
  facade.register_command(Notifications::MULTIPLEX_FILE, MultiplexFileCommand.new)
  
  facade.register_command(Notifications::CLEANUP_FILES, CleanUpEncodingJobCommand.new)
  
  #Initialize the Mediator
  facade.register_mediator(LoggerMediator.new)
  facade.register_mediator(ScreenMediator.new)
  
  #Fire off the very first command with a notification
  facade.send_notification(Notifications::VALIDATE_PROGRAM_ARGS)
end

main