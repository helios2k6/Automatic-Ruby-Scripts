

VideoQualityVector = ["480", "720", "1080"]
AudioCodecVector = ["AAC", "FLAC", "Vorbis", "OGG", "M4A"]

BracketRegularExpression = /\[\w*\]/

def allPossibleQualityTags()
	
end

def searchNthSubgroupBracketSubgroup(fileName, groupNumber = 0)
	subGroup = fileName.scan(BracketRegularExpression)
	
	if subGroup != nil then
		return subGroup[groupNumber]
	end
	
	return nil
end

def searchQualityTag(fileName)
	subGroup = fileName.scan(BracketRegularExpression)
	
	if subGroup != nil then
		subGroup.each{|e|

		}
	end
end