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
require './MediaObjects'
require './Constants'

module AudioEncoders
	class FlacDecoder
		DECODING_ARG = "-d"

		OUTPUT_ARG = "-o"

		def self.generateDecodeFlacToWavCommand(file)
			outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::WAV]
			command = "#{Constants::AudioExecutables::FLAC} #{DECODING_ARG} \"#{file}\" #{OUTPUT_ARG} \"#{outputFile}\""

			return [command, outputFile]
		end
	end
	
	class AacEncoder
		TWO_CHANNEL_BITRATE = 96000
		SIX_CHANNEL_BITRATE = 256000

		OUTPUT_ARG = "-of"

		INPUT_ARG = "-if"
		
		BITRATE_ARG = "-br"

		def self.generateEncodeWavToAacCommand(file, sixChannelBitrate=false)
			bitrate = TWO_CHANNEL_BITRATE
			if sixChannelBitrate then
				bitrate = SIX_CHANNEL_BITRATE
			end
			outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::AAC]
			command = "#{Constants::AudioExecutables::NERO_AAC} #{BITRATE_ARG} #{bitrate} #{INPUT_ARG} \"#{file}\" #{OUTPUT_ARG} \"#{outputFile}\""
			return [command, outputFile]
		end
	end

	class FFMpegDecoder
		INPUT_ARG = "-i"
		AUDIO_CODEC_ARG = "-acodec"

		WAV_CODEC = "pcm_s16le"

		def self.generateDecodeAudioToWav(file)
			outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::WAV]
			command = "#{Constants::AudioExecutables::FFMPEG} #{INPUT_ARG} \"#{file}\" #{AUDIO_CODEC_ARG} #{WAV_CODEC} \"#{outputFile}\""

			return [command, outputFile]
		end
	end	
end