def checkFile(file)
	ext = File.extname(file)
	return file != "." && file != ".." && (ext.casecmp(".png") == 0 || ext.casecmp(".jpg") == 0 || ext.casecmp(".jpeg") == 0 || ext.casecmp(".gif") == 0)
end

def processFolder(rootNameString, files, startIndex=1)
	tempFiles = []
	i = startIndex
	files.each{|f|
		ext = File.extname(f)
		if checkFile(f) then
			ext = File.extname(f)
			properName = File.basename(f, ext)
			tempName = "TEMP_NAME (#{i})#{ext}"
			File.rename(f, tempName)
			puts("rename #{f} to #{tempName}")
			tempFiles << tempName
			i = i + 1
		end
	}
	
	i = startIndex
	tempFiles.each{|f|
		ext = File.extname(f)
		if checkFile(f) then
			ext = File.extname(f)
			newName = "#{rootNameString} (#{i})#{ext}"
			File.rename(f, newName)
			puts("Rename #{f} to #{newName}")
			i = i + 1
		end
	}
end

def main
	rootNameString = ARGV[0]
	startIndex = 0
	if ARGV.length >= 2 then
		startIndex = ARGV[1].to_i
	end
	
	processFolder(ARGV[0], Dir.new("."), startIndex)
end

main