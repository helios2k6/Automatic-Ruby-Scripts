require './FileRenamingUtilities'

def main
	rootNameString = ARGV[0]
	startIndex = 0
	if ARGV.length >= 2 then
		startIndex = ARGV[1].to_i
	end
	
	FileRenamingUtilities::Pictures::renameFilesInFolder(rootNameString, Dir.new("."), startIndex)
end

main