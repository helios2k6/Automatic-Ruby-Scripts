module FileRenamingUtilities
    class Pictures
        def self.isFilePicture?(file)
            ext = File.extname(file)
            
            return (File.file?(file) && file != "." && file != ".." && (ext.casecmp(".png") == 0 || ext.casecmp(".jpg") == 0 || ext.casecmp(".jpeg") == 0 || ext.casecmp(".gif") == 0))
        end
        
        def self.renameFilesInFolder(rootNameString, files, startIndex=1)
            pictureFiles = []
            tempFiles = []
            i = startIndex
            # Grab all the picture files. We have to prepopulate this 
            # because if we don't, then when we go to rename a file, the
            # "files iterator" will actually yield the temporary file and
            # we'll end up renaming the temporary file over and over again 
            # until we hit the INT_MAX limit
            files.each{|f|
                ext = File.extname(f)
                if isFilePicture?(f) then
                    pictureFiles << f
                end
            }
            pictureFiles.each{|f|
                ext = File.extname(f)
                properName = File.basename(f, ext)
                tempName = "TEMP_NAME (#{i})#{ext}"
                File.rename(f, tempName)
                puts("rename #{f} to #{tempName}")
                tempFiles << tempName
                i = i + 1
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