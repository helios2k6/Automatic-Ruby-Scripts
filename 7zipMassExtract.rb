SEVEN_ZIP = "7z.exe"

ARCHIVE_ARG = "--archive"
PASSWORD_ARG = "--password"
DESTINATION_ARG = "--destination"
EXTENSION_ARG = "--extension"
HELP_ARG = "--help"

class Archive
	attr_accessor :rootFile, :password, :destination, :extension
	
	def initialize(rootFile)
		@rootFile = rootFile
		@password = nil
		@destination = "."
		@extension = ".rar"
	end
end

def printHelp
	helpString = []
	
	helpString.push("7zip Mass Extractor for Raws")
	helpString.push("Author: Andrew Johnson")
	helpString.push("")
	
	helpString.push("Usage: ruby <this script> [options]")
	helpString.push("")
	
	helpString.push("Options:")
	
	#Print help
	helpString.push("\t#{HELP_ARG}")
	helpString.push("\t\tPrint this help screen")
	
	helpString.push("")
	
	#Root archive names
	helpString.push("\t#{ARCHIVE_ARG} [<root_file_name 1>;<root_file_name 2>;...]")
	helpString.push("\t\tThe name(s) of the root archive file(s) you want to extract.")
	helpString.push("\t\tAll archives must be in THIS folder.")
	
	helpString.push("")
	
	#Passwords
	helpString.push("\t#{PASSWORD_ARG} [<archive password 1>;<archive password 2>;...]")
	helpString.push("\t\tThe password(s) of the archive(s) you want to use to extract.")
	helpString.push("\t\tIf only one password is given, it will be used for all files.")
	helpString.push("\t\tIf the number of passwords given is less than the number of files,")
	helpString.push("\t\tthen the last password will be used on the remaining files.")
	
	helpString.push("")
	
	#Destination
	helpString.push("\t#{DESTINATION_ARG} [<folder 1>;<folder 2>;...]")
	helpString.push("\t\tThe destination folder you want the extract files to go")
	
	helpString.push("")
	
	#Extension
	helpString.push("\t#{EXTENSION_ARG} [<root archive extension 1>;<root archive extension 2>;...]")
	helpString.push("\t\tThe archive extensions of the files.")
	helpString.push("\t\tDefault = .rar")
	
	helpString.push("")
	
	#Print strings
	helpString.each{|e| puts(e)}
end


def extractFile(file, destination, password=nil)
	if password == nil then
		command = "\"#{SEVEN_ZIP}\" x -o#{destination} \"#{file}\""
		system(command)
	else
		command = "\"#{SEVEN_ZIP}\" x -p#{password} -o#{destination} \"#{file}\""
		system(command)
	end
end

def isPrimaryArchive(name, rootArchiveName, extension)
	result = name.scan(/((#{rootArchiveName})\.(part)\d{1,}\.(part01#{extension}))/)
	result2 = name.scan(/((#{rootArchiveName})\.(part)\d{1,}\.(part1#{extension}))/)
	
	if result.size > 0 || result2.size > 0 then
		return true
	else
		return false
	end
end

def isChosenArchive(file, archive)
	return isPrimaryArchive(file, archive.rootFile, archive.extension)
end

def processFile(file, archives)
	for a in archives
		if isChosenArchive(file, a) then
			extractFile(file, a.destination, a.password)
		end
	end
end

def processArchives(archives)
	cd = Dir.new(".")
	cd.each{|file| processFile(file, archives)}
end

def doesUserWantHelp(argVector)
	for a in argVector
		if a.casecmp(HELP_ARG) == 0 then
			return true
		end
	end
	
	return false
end

def processArgs(argVector)
	if argVector.size < 1 || doesUserWantHelp(argVector) then
		printHelp
		exit
	end
	
	allArchivesObjects = []
	
	i = 0
	
	allArchives = []
	allPasswords = []
	allDestinations = []
	allExtensions = []
	
	begin
		while i < argVector.size
			currentArg = argVector[i]
			currentValue = argVector[i+1]
			case currentArg
				when ARCHIVE_ARG
					allArchives = currentValue.split(";")
				when PASSWORD_ARG
					allPasswords = currentValue.split(";")
				when DESTINATION_ARG
					allDestinations = currentValue.split(";")
				when EXTENSION_ARG
					allExtensions = currentValue.split(";")
			end
			
			i = i + 2
		end
	rescue
		puts "Arguments given didn't match up"
		exit(1)
	end
	
	lastPassword = nil
	lastDestination = nil
	
	for i in (0...allArchives.size)
		currentArchiveFile = allArchives[i]
		currentPassword = allPasswords[i]
		currentDestination = allDestinations[i]
		currentExtension = allExtensions[i]
		
		archiveObject = Archive.new(currentArchiveFile)
		
		if currentPassword != nil then
			lastPassword = currentPassword
			
			archiveObject.password = lastPassword
		elsif lastPassword != nil then
			archiveObject.password = lastPassword
		end
		
		if currentDestination != nil then
			lastDestination = currentDestination
			
			archiveObject.destination = lastDestination
		elsif lastDestination != nil then
			archiveObject.destination = lastDestination
		end
		
		if currentExtension != nil then
			archiveObject.extension = currentExtension
		end
		
		allArchivesObjects.push(archiveObject)
	end
	
	return allArchivesObjects
end

def main
	allArchives = processArgs(ARGV)
	processArchives(allArchives)
end

main