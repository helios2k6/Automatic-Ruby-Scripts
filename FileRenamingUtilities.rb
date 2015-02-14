module FileRenamingUtilities
    class Pictures
        def self.isFilePicture?(file)
            ext = File.extname(file)
            
            return (File.file?(file) && file != "." && file != ".." && (ext.casecmp(".png") == 0 || ext.casecmp(".jpg") == 0 || ext.casecmp(".jpeg") == 0 || ext.casecmp(".gif") == 0))
        end
        
        def self.renameFilesInFolder(rootNameString, files, startIndex=1)
            tempFiles = []
            i = startIndex
            files.each{|f|
                ext = File.extname(f)
                if isFilePicture?(f) then
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
                if isFilePicture?(f) then
                    ext = File.extname(f).downcase
                    newName = "#{rootNameString} (#{i})#{ext}"
                    File.rename(f, newName)
                    puts("Rename #{f} to #{newName}")
                    i = i + 1
                end
            }
        end
    end
end