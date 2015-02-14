require './FileRenamingUtilities'
require 'fileutils'

def grabLatestAnimeFileNumber(folder, prefix)
    latestNumber = -1
    prefixRegex = /(#{prefix})(\s)(\()(\d*)(\))/
    Dir.new(folder).each{|f|
        if FileRenamingUtilities::Pictures::isFilePicture?("#{folder}/#{f}") then
            matches = f.scan(prefixRegex)
            if not matches.empty? then
                firstGroup = matches[0]
                if (firstGroup != nil) && (not firstGroup.empty?) then
                    number = firstGroup[3].to_i
                    if latestNumber < number then
                        latestNumber = number
                    end
                end
            end
        end
    }
    
    return latestNumber
end

def getLatestAnimeFolder(prefix)
    prefixRegex = /(#{prefix})(\s)(\d*)(-)(\d*)/
    latestFolder = nil
    latestNumber = nil
    Dir.new(".").each{|f|
        if File.directory?(f) then
            matches = f.scan(prefixRegex)
            if not matches.empty? then
                firstGroup = matches[0]
                if (firstGroup != nil) && (not firstGroup.empty?) then
                    currentNumber = firstGroup[4].to_i
                    if latestFolder == nil || latestNumber == nil || latestNumber < currentNumber then
                        latestFolder = f
                        latestNumber = currentNumber
                    end
                end
            end
        end
    }
    
    return latestFolder
end

def moveFiles(destFolder)
    Dir.new(".").each{|f|
        if FileRenamingUtilities::Pictures::isFilePicture?(f) then
            FileUtils.mv(f, "#{destFolder}/#{f}", :force => false, :verbose => true)
        end
    }
end

def main
    prefix = ARGV[0]
    latestFolder = getLatestAnimeFolder(prefix)
    latestNumber = grabLatestAnimeFileNumber(latestFolder, prefix)
    FileRenamingUtilities::Pictures::renameFilesInFolder(prefix, Dir.new("."), latestNumber + 1)
    moveFiles(latestFolder)
end

main