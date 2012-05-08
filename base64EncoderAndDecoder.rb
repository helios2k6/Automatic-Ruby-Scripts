def encodeFile(file, outputFile)
	fd = File.new(file, "rb")
	arrayOfBytes = Array.new

	fd.each_byte{|b|
		arrayOfBytes << b
	}

	packedString = [arrayOfBytes.pack("N*")].pack("m*")

	resultFile = File.new(outputFile, "w")
	resultFile.print(packedString)
	resultFile.close
end

def decodeFile(file, outputFile)
	fd = File.new(file, "r")

	fileText = ""

	fd.each{|l|
		fileText << l
	}

	unpackedBinaryString = (fileText.unpack("m*")[0]).unpack("N*").pack("C*")

	resultFile = File.new(outputFile, "wb")
	resultFile.print(unpackedBinaryString)
	resultFile.close
end

def main
	if ARGV[0].casecmp("decode") == 0 then
		decodeFile(ARGV[1], ARGV[2])
	else
		encodeFile(ARGV[1], ARGV[2])
	end
end

main