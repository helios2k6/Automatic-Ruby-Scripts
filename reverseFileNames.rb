INDEX_SCAN = /(\(\d+\))/

#File.basename(x, File.extname(x)).split(/\(\d+\)/)[0].chomp(" ")

def renameFiles(arr)
	y = []
	l = []
	
	m = Hash.new
	
	ext = []
	
	arr_c = []
	
	arr.each{|e|
		firstRound = e.scan(INDEX_SCAN)
			if firstRound[0] != nil then
		
				currentIndex1 = firstRound[0][0]
				currentIndex = currentIndex1.scan(/\d+/)[0].to_i
				
				y << currentIndex
				
				ext << File.extname(e)
				l << File.basename(e, File.extname(e)).split(/\(\d+\)/)[0].chomp(" ")
				
				arr_c << e				
			end
		}
		
		y.reverse!
		
		i = 0
		
		arr_c.each{|e|
			m[e] = "#{l[i]} (#{y[i]})_renamed#{ext[i]}"
			i = i + 1
		}
		
		m.each{|key,value|
			puts "naming #{key} to #{value}"
			File.rename(key, value)
		}
	
end

def main
	cd = Dir.new(".")
	
	x = []
	
	cd.each{|e|
		x << e
	}
	
	x.delete(".")
	
	x.delete("..")
	
	renameFiles(x)	
end

main