GUNDAM_00_ROOT = "Gundam 00"
EXTENSION = ".mkv"

X264_ROOT_COMMAND = "x264 --qp 0 --min-keyint 12 --pass 1 --output NUL --sar 1:1"

def processFile(file)
	thisFileExt = File.extname(file)
	baseName = File.basename(file, EXTENSION)
	if thisFileExt == EXTENSION then
		avsFile = autogen_avs(file)
		command = X264_ROOT_COMMAND + " --stats \"#{baseName}.log\" \"#{avsFile}\""
		puts("Executing #{command}")
		system(command)
	end
end

def autogen_avs(file)
	avs_file = File.open("#{File.basename(file, EXTENSION)}.avs", 'w')
	script = "x = \"#{file}\"\nffindex(x)\nffvideosource(x)"
	avs_file.puts(script)
	avs_file.flush
	avs_file.close
	return File.basename(file, EXTENSION) + ".avs"
end

def main()
	dir = Dir.new(".")
	dir.each{|x| processFile(x)}
end

main()