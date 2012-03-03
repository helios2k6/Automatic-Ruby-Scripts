require './MediaObjects'
require './Constants'

module AudioEncoders
  class FlacDecoder
    FLAC = "flac"

    DECODING_ARG = "-d"

    OUTPUT_ARG = "-o"

    def self.generateDecodeFlacToWavCommand(file)
      outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::WAV]
      command = FLAC + " " + DECODING_ARG + " \"#{file}\" #{OUTPUT_ARG} \"#{outputFile}\""

      return [command, outputFile]
    end
  end

  class OggDecoder
    OGG_DECODER = "oggdec"

    OUTPUT_ARG = "-w"

		def self.generateDecodeOggToWavCommand(file)
			outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::WAV]
			command = OGG_DECODER + " " + OUTPUT_ARG + " \"#{outputFile}\" \"#{file}\""

			return [command, outputFile]
		end
	end
	
    class AacEncoder
      NERO_AAC = "neroAacEnc"

      BITRATE = 96000

      OUTPUT_ARG = "-of"

      ARG = "-br #{BITRATE} -if"

      def self.generateEncodeWavToAacCommand(file)
        outputFile = File.basename(file, File.extname(file)) << Constants::TrackFormat::EXTENSION_HASH[Constants::TrackFormat::AAC]
        command = NERO_AAC + " " + ARG + " \"#{file}\" #{OUTPUT_ARG} \"#{outputFile}\""
        return [command, outputFile]
      end
    end
	
end