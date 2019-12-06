FFMPEG_BASE_COMMAND = "ffmpeg"
FFMPEG_INPUT_ARG = "-i"
FFMPEG_FPS_ARG = "-vf fps=1/40"
FFMPEG_OUTPUT_ARG_SUFFIX = "out_%02d.jpg"
MKV_EXTENSION = ".mkv";

def getPictures(file)
	outputArg = "#{File.basename(file, MKV_EXTENSION)}_#{FFMPEG_OUTPUT_ARG_SUFFIX}"
	extractionCommand = "#{FFMPEG_BASE_COMMAND} #{FFMPEG_INPUT_ARG} \"#{file}\" #{FFMPEG_FPS_ARG} \"#{outputArg}\""
	
	puts extractionCommand
	system(extractionCommand)
end

def processFile(file)
	fileExtension = File.extname(file)
	
	if fileExtension.casecmp(MKV_EXTENSION) == 0 then
		getPictures(file)
	end
	
	return nil
end

def main
	cd = Dir.new(".")
	cd.each{|file|
		encodedFile = processFile(file)
	}
end

main
