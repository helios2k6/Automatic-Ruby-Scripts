FundimentalMatch = /(\(\d+\))/

AcceptedExtentions = [".mp4", ".mkv", ".avi", ".wmv"]

def processFile(file, knownFiles)
	extName = File.extname(file)
	if File.directory?(file) || !AcceptedExtentions.include(extName)? then
		return
	end

	baseName = File.basename(file, extName)
	
	fundimentalName = baseName.split(FundimentalMatch)[0]
	
	if !knownFiles.include(fundimentalName)? then
		knownFiles[file] = fundimentalName
		#Dir.mkdir("./#{fundimentalName}")
		puts("Directory #{fundimentalName} created")
	end
	
	#File.rename(file, "#{fundimentalName}/#{file}")
	puts("#{file} moved to #{fundimentalName}/#{file}")
end

def main
	cd = Dir.new(".")
	knownFiles = Array.new
	cd.each{|f|
		processFile(f, knownFiles)
	}	
end

main