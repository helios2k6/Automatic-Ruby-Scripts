require 'time'
require 'ostruct'

def tryParseTime(timeString)
  begin
    return Time.parse(timeString)
  rescue ArgumentError
    return nil;
  end
end

def getTimesForProject(projectName)
  puts "Enter times for project: #{projectName}"
  projectTimes = []
  loop {
    controlVariable = gets.chomp
    
    break if controlVariable.casecmp("END") == 0
    
    maybeParsedTime = tryParseTime(controlVariable)
    if maybeParsedTime != nil then
      timeStruct = OpenStruct.new
      timeStruct.project = projectName
      timeStruct.time = maybeParsedTime
      projectTimes << timeStruct
    else
      puts "Invalid time format input. Try again. Type \"END\" if you want to break out of this loop"
    end
  }
  return projectTimes
end

def calculateProjectTimes(allProjects)
  # get all values
  allProjectTimes = allProjects.values.flatten(1)
  puts allProjectTimes

  # sort array by project and time, with I/O being the only project that can break a tie
  sortedProjectTimes = allProjectTimes.sort { |a, b|
    if ((a.time) - (b.time)) == 0 then
      if a.project.casecmp "I/O" == 0 then
        return 1
      elsif b.project.casecmp "I/O" == 0 then
        return -1
      else
        return 0
      end
    else
      return a.time <=> b.time
    end
  }
  puts sortedProjectTimes
  projectTimeTrackers = Hash.new
  ioProjectTimeHolder = nil
  previousProject = nil
  sortedProjectTimes.each { |currentProject|
    # first, add the key to the has if it doesn't exist
    if projectTimeTrackers.has_key?(currentProject.project) == false then
      projectTimeTrackers[currentProject.project] = 0
    end
    
    # second, take the previous project and calculate the duration
    if previousProject != nil then
      timeDiff = currentProject.time - previousProject.time
      projectTimeTrackers[currentProject.project] = projectTimeTrackers[currentProject.project] + timeDiff
    end
    
    # now, if this is the IO project, set the ioProjectTimeHolder variable to the PREVIOUS project
    if currentProject.project.casecmp "I/O" == 0 then
      ioProjectTimeHolder = previousProject
    #if this is NOT the I/O project, but the ioProjectTimeHolder variable was set, then calculate the time for that project
    elsif ioProjectTimeHolder != nil then
      timeDiff = currentProject.time - previousProject.time
      projectTimeTrackers[ioProjectTimeHolder.project] = projectTimeTrackers[ioProjectTimeHolder.project] + timeDiff
    end
    
    previousProject = currentProject
  }
  
  return projectTimeTrackers
end

def main
  puts "Rollover Script"
  ioProjectTimes = getTimesForProject("I/O")
  allProjects = Hash["I/O" => ioProjectTimes]
  loop {
    puts "Enter next project or \"END\" if you want to exit the loop"
    projectName = gets.chomp

    break if projectName.casecmp("END") == 0

    if allProjects.has_key?(projectName) then
      puts "The project #{projectName} already exists. Enter a new project"
    else
      currentProjectTimes = getTimesForProject(projectName)
      allProjects[projectName] = currentProjectTimes
    end
  }

  allProjectTimes = calculateProjectTimes(allProjects)
  allProjectTimes.each { |project, time|
    puts "#{project} : #{time / 60} Minutes"
  }
end

main