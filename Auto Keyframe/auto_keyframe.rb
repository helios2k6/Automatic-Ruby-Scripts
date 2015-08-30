GUNDAM_00_ROOT = "Gundam 00"
EXTENSION = ".mkv"


X264_ROOT_COMMAND = "x264 --qp 0 --pass 1 --output NUL"

def autogen_avs(file)
	avs_file = File.open("#{File.basename(file, EXTENSION)}.avs", 'w')
	script = "x = \"#{file}\"\nffindex(x)\nffvideosource(x)"
	avs_file.puts(script)
	avs_file.flush
	avs_file.close
	return File.basename(file, EXTENSION) + ".avs"
end

def main
	for i in (6..10)
		root = GUNDAM_00_ROOT + " (#{i})"
		currentGundam = root + EXTENSION
		avsFileName = autogen_avs(currentGundam)
		system(X264_ROOT_COMMAND + " --stats \"#{root}.log\" \"#{avsFileName}\"")
	end
end

main