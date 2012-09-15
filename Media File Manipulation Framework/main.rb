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

require 'rubygems'
require 'PureMVC_Ruby'
require './Constants'
require './ScreenObjects'
require './AudioEncoders'
require './Commands'
require './Executors'
require './InputModule'
require './Loggers'
require './MediaObjects'
require './MediaTaskObjects'
require './ScreenMediators'

def main
	facade = Facade.instance

	#Initialize All Proxies
	facade.register_proxy(MediaTaskObjects::EncodingJobsProxy.new)
	facade.register_proxy(Loggers::LoggerProxy.new)
	facade.register_proxy(InputModule::ProgramArgsProxy.new(ARGV))
	facade.register_proxy(Executors::ExecutorProxy.new)
	facade.register_proxy(ScreenObjects::ScreenProxy.new)
	facade.register_proxy(MediaObjects::MediaFileProxy.new)
	facade.register_proxy(MediaTaskObjects::EncodedFileProxy.new)
	facade.register_proxy(MediaTaskObjects::AvisynthFileProxy.new)
	facade.register_proxy(MediaTaskObjects::TemporaryFilesProxy.new)

	#Initialize All Commands
	facade.register_command(Constants::Notifications::PRINT_HELP, Commands::PrintHelpCommand)

	facade.register_command(Constants::Notifications::EXECUTE_EXTERNAL_COMMAND, Commands::FireExternalExecutionCommand)
	facade.register_command(Constants::Notifications::EXTERNAL_COMMAND_EXECUTED, Commands::HandleExternalExecutionOutputCommand)

	facade.register_command(Constants::Notifications::EXIT_SUCCESS, Commands::ExitCommand)
	facade.register_command(Constants::Notifications::EXIT_FAILURE, Commands::ExitCommand)

	facade.register_command(Constants::Notifications::VALIDATE_PROGRAM_ARGS, Commands::ValidateProgramArgsCommand)
	
	facade.register_command(Constants::Notifications::LAUNCH_ENCODING_CYCLE_MACRO_COMMAND, Commands::LaunchEncodingCycleMacroCommand)

	facade.register_command(Constants::Notifications::RETRIEVE_MEDIA_FILES, Commands::RetrieveAllMediaFilesCommand)
	facade.register_command(Constants::Notifications::GENERATE_ENCODING_JOBS, Commands::GenerateEncodingJobsCommand)

	facade.register_command(Constants::Notifications::EXECUTE_ALL_ENCODING_JOBS, Commands::ExecuteAllEncodingJobsCommand)

	facade.register_command(Constants::Notifications::EXTRACT_AUDIO_TRACK, Commands::ExtractAudioTrackCommand)
	facade.register_command(Constants::Notifications::EXTRACT_SUBTITLE_TRACK, Commands::ExtractSubtitleTrackCommand)

	facade.register_command(Constants::Notifications::GENERATE_AVISYNTH_FILE, Commands::GenerateAvisynthFileCommand)

	facade.register_command(Constants::Notifications::ENCODE_FILE, Commands::EncodeFileCommand)

	facade.register_command(Constants::Notifications::MULTIPLEX_FILE, Commands::MultiplexFileCommand)

	facade.register_command(Constants::Notifications::CLEANUP_FILES, Commands::CleanUpEncodingJobCommand)

	facade.register_command(Constants::Notifications::OUTPUT_COPYLEFT, Commands::OutputCopyLeftNotice)

	#Initialize the Mediator
	facade.register_mediator(Loggers::LoggerMediator.new)
	facade.register_mediator(ScreenMediators::ScreenMediator.new)

	#Show copyleft notification
	facade.send_notification(Constants::Notifications::OUTPUT_COPYLEFT)
	
	#Fire Validate Command
	facade.send_notification(Constants::Notifications::VALIDATE_PROGRAM_ARGS)
	
	#Launch Macro Command
	facade.send_notification(Constants::Notifications::LAUNCH_ENCODING_CYCLE_MACRO_COMMAND)
end

main