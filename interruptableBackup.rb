HB_BINARY = "hb"
BACKUP_OPTION = "backup -c"
BLACK_LIST_DIRECTORIES = { '.' => '.', '..' => '..' }

$GLOBAL_INTERRUPT_COUNT = 0
$GLOBAL_SHOULD_EXIT_AFTER_CURRENT_BACKUP = false

def printHelp
  puts "Interruptable Backup v1.0"
  puts "Continuously backs up a root folder until SIGINT (Ctrl+C) is sent to it"
  puts "Usage: ruby <this script> <absolute path to hb backup directory> <absolute path to top level directory to backup> <save file>"
end

def saveBackedUpFolders(hashOfSavedFiles, saveFile)
  # Now, save the file
  File.open(saveFile, 'w+') { |fileHandle|
    hashOfSavedFiles.each{ |key, value|
      fileHandle.puts(key)
    }
  }

end

def loadSavedFolders(saveFile)
  fileHash = Hash.new
  if File.exist?(saveFile) then
    File.foreach(saveFile) { |line| 
      strippedLine = line.strip
      fileHash[strippedLine] = strippedLine
    }
  end
  fileHash
end

def backupSubFolder(pathToHbBackupFolder, pathToFolderToBackup)
  command = "#{HB_BINARY} #{BACKUP_OPTION} #{pathToHbBackupFolder} \"#{pathToFolderToBackup}\""
  puts "Executing command: #{command}"
  sleep(5)
  #system(command)
end

def getAllSubFolders(pathToRootDirectory, savedFolders)
  currentDirectory = Dir.pwd
  Dir.chdir(pathToRootDirectory)
  allSubFolders = Dir.glob("*/").map{ |folder|
    File.absolute_path(folder)
  }.select{ |elem|
    !(BLACK_LIST_DIRECTORIES.has_key?(elem)) && !(savedFolders.has_key?(elem))
  }
  Dir.chdir(currentDirectory)

  allSubFolders
end

def backupRootFolder(pathToHbDirectory, pathToRootDirectory, pathToSaveFile)
  savedFilesHash =  loadSavedFolders(pathToSaveFile)
  getAllSubFolders(pathToRootDirectory, savedFilesHash).each{ |folder|
    if !$GLOBAL_SHOULD_EXIT_AFTER_CURRENT_BACKUP then
      backupSubFolder(pathToHbDirectory, folder)
      savedFilesHash[folder] = folder
    end
  }

  savedFilesHash
end

def main
  if ARGV.size < 3 then
      printHelp
      exit
  end

  # Be careful with this signal handler--we need to signal that we should exit this process
  # once we finish 
  Signal.trap("INT") {
    $GLOBAL_INTERRUPT_COUNT = $GLOBAL_INTERRUPT_COUNT + 1
    if $GLOBAL_INTERRUPT_COUNT > 1 then
      puts "Shutting down immediately!"
      exit(1)
    else
      puts "Interrupt Signal Received. Shutting down after current backup is complete"
      $GLOBAL_SHOULD_EXIT_AFTER_CURRENT_BACKUP = true
    end
  }

  pathToHbDirectory = ARGV[0]
  pathToRootDirectory = ARGV[1]
  pathToSaveFile = ARGV[2]

  savedFilesHash = backupRootFolder(pathToHbDirectory, pathToRootDirectory, pathToSaveFile)
  saveBackedUpFolders(savedFilesHash, pathToSaveFile)
end

main
