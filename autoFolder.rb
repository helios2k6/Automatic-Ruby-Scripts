FundimentalMatch = /(\(\d+\))/

AcceptedExtentions = [".mp4", ".mkv", ".avi", ".wmv"]

def processFile(file)
	extName = File.extname(file)
	if File.directory?(file) || !AcceptedExtentions.include?(extName) then
		return
	end

	baseName = File.basename(file, extName)
	
	fundimentalName = (baseName.split(FundimentalMatch)[0]).strip
	
	if !Dir.exists?(fundimentalName) then
		Dir.mkdir("./#{fundimentalName}")
		puts("Directory \"#{fundimentalName}\" created")
	end
	
	File.rename("#{file}", "./#{fundimentalName}/#{file}")
	puts("\"#{file}\" moved to \"./#{fundimentalName}/#{file}\"")
end

def main
	cd = Dir.new(".")
	cd.each{|f|
		processFile(f)
	}	
end

main