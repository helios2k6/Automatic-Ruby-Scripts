GarbageCharacterVector = ["_"]

VideoQualityVector = ["480", "720", "1080"]
VideoCodecVector = ["H264", "XVID"]
AudioCodecVector = ["AAC", "FLAC", "Vorbis", "OGG", "M4A"]

BracketRegularExpression = /\[\w*\]/
ParenthesisRegularExpression = /\(\w*\)/

def allPossibleQualityTags()
	return []
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
