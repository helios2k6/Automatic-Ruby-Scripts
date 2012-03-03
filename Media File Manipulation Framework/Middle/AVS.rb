module AVS
	def self.generateAVSFile(mediaFile, extraFilters=nil)
		avsFileName = File.basename(mediaFile, File.extname(mediaFile)) + ".avs"
		avsFile = File.open(avsFileName, 'w')
		script = "x = \"#{mediaFile}\"\n
		ffindex(x)\n
		y = directshowsource(x) #Add this line so we can get the fonts\n
		ffvideosource(x, fpsnum=24000, fpsden=1001)\n
		gradfun2db()\n"		
		avsFile.puts(script)
		if extraFilters != nil then
			avsFile.puts(extraFilters)
		end

		avsFile.close
		
		return avsFileName
	end
end