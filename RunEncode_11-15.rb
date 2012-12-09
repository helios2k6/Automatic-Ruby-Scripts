DirectoryBase = "H:\\Encoding Platform\\Gundam 00 S2"

def main
	for i in 11..15
		currentDirectory = "#{DirectoryBase}\\#{i}"
		
		currentCommand = ["x264_fade", "--colormatrix", "bt709", "--crf", "16", "--aq-strength", "1.5", "--b-pyramid", "none", "--fade-compensate", "0.2", "--psy-rd", "0.3", "--me", "umh", "--min-keyint", "23", "--subme", "10", "--trellis", "2", "--psnr", "--ssim", "--aud", "--sar", "1:1", "--level", "4.1", "--profile", "high", "--output", "Stage A.264", "Stage A.avs", :chdir => currentDirectory]
		
		streams = IO.popen(currentCommand)
		
		puts currentDirectory
		$stdout.flush
		
		while !streams.eof?
			puts streams.read
			$stdout.flush
		end
	end
end

main