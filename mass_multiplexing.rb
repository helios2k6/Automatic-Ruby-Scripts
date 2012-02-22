EXTENTION = ".264"

def processFile(file)
	if File.extname(file) == EXTENTION then
		basename = File.basename(file, File.extname(file))
		
		audio = basename + "_track2.aac"
		
		command = "MP4Box -add \"#{file}\" -add \"#{audio}\" -new \"#{basename}.mp4\""
		puts("Executing Command " + command)
		
		system(command)
	end
end

def main()
	dir = Dir.new(".")
	dir.each{|x| processFile(x)}
end

main()