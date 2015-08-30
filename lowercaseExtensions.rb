def lowercaseExtFile(file)
    ext = File.extname(file)
    fileName = File.basename(file, ext)
    newName = "#{fileName}#{ext.downcase}"
    File.rename(file, newName)
end

def main
    Dir.new(".").each{|f|
        if(f != "." && f!= "..") then
            lowercaseExtFile(f)
        end
    }
end

main