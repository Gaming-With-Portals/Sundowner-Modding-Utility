extends Node
var VALID_EXTENSIONS = ["dat", "dtt", "env", "eff", "eft"]
var packed_bytes_0 : PackedByteArray = [0x00]
var global_folders = []
var compile_heirarchy = []


# DAT DTT, AND OTHER MGRR DATA FILES
func readint32array(length, data):
	var array = []

func readstring(reader, length):
	var bytes = reader.get_buffer(length)
	return bytes.get_string_from_utf8()
	
func readstringarray(reader, len, arrlen):
	var List = []
	for i in arrlen:
		List.append(readstring(reader, len))
	return List
	
func Load(data):
	var nameSize = 1
	var DatHeader = load("res://scenes/structs/DatHeaders.gd").new()
	var Files = []
	
	var reader = FileAccess.open(data, FileAccess.READ)
	
	
	
	DatHeader.Magic = readstring(reader, 4)
	DatHeader.FileAmount = reader.get_32()
	DatHeader.PositionsOffset = reader.get_32()
	DatHeader.ExtensionsOffset = reader.get_32()
	DatHeader.NamesOffset = reader.get_32()
	DatHeader.SizesOffset = reader.get_32()
	DatHeader.HashMapOffset = reader.get_32()


	reader.seek(DatHeader.PositionsOffset)
	var fileOffsets = []
	for x in DatHeader.FileAmount:
		fileOffsets.append(reader.get_32())
	
	# File Sizes
	reader.seek(DatHeader.SizesOffset)
	var fileSizes = []
	for x in DatHeader.FileAmount:
		fileSizes.append(reader.get_32())	
	
	# File Names
	reader.seek(DatHeader.NamesOffset)
	nameSize = reader.get_32()
	var fileNames = readstringarray(reader, nameSize, DatHeader.FileAmount)
		
	for x in DatHeader.FileAmount:
		var filePosition = fileOffsets[x]
		var fileSize = fileSizes[x]
		var fileName = fileNames[x]
		
		reader.seek(filePosition)
		
		var tempfile = load("res://scenes/structs/DatFileEntry.gd").new()
		tempfile.Data = reader.get_buffer(fileSize)
		tempfile.Name = fileName
		Files.append(tempfile)
		
		
	return Files


	

func CalcPadding(blocksize, length):
	return blocksize - (length % blocksize)

func pad_string(string, padding_length):
	return padding_length - len(string)


func Save(Files, outputdir):

	
	
	var deny_list := ["\n"]
	# GET HASH DATA
	var tools_path = OS.get_executable_path().get_base_dir() + "/pmc/hash/"
	
	var arguments = ["file_names"]
	for file in Files:
		arguments.append(file.Name)
	
	var output = []
	OS.execute(tools_path + "MGRRHashGenerator.exe", arguments, output)
	var new_output = ""
	for position in output[0].length():
		var current_character = output[0][position]
		if not deny_list.has(current_character):
			new_output += current_character
	
	var output_array = new_output.split("\r")
	# Prehash
	var PrehashShift = int(output_array[0])
	var BucketOffsets = []
	var Hashes = []
	var Indices = []
	var StructSize
	
	# Bucket Offsets
	var isreading = false
	for item in output_array:
		if item == "HASHES_BEGIN":
			isreading = false
			
		if isreading:
			BucketOffsets.append(int(item))
			
		if item == "BUCKET_OFFSET_BEGIN":
			isreading = true

	
	# READ HASHES
	isreading = false
	for item in output_array:
		if item == "INDICES_BEGIN":
			isreading = false
			
		if isreading:
			Hashes.append(int(item))
			
		if item == "HASHES_BEGIN":
			isreading = true
	
	# READ INDICES
	isreading = false
	for item in output_array:
		if item == "END":
			isreading = false
			
		if isreading:
			Indices.append(int(item))
			
		if item == "INDICES_BEGIN":
			isreading = true
			
	StructSize = int(output_array[output_array.find("END", 0) + 1])



	var DatHeader = load("res://scenes/structs/DatHeaders.gd").new()
	
	
	var LongestFilename = 0
	
	var offsets = []
	var sizes = []
	var extensions = []
	var names = []
	
	# TODO implement optimization i made
	for file in Files:
		if LongestFilename < len(file.Name):
			LongestFilename = len(file.Name)
		
		sizes.append(len(file.Data))
		extensions.append(file.Name.get_extension())
		names.append(file.Name)
	
	LongestFilename+=1

	DatHeader.FileAmount = len(Files)
	DatHeader.PositionsOffset = 0x20;
	DatHeader.ExtensionsOffset = 0x20 + (4 * DatHeader.FileAmount)
	DatHeader.NamesOffset = DatHeader.ExtensionsOffset + (4 * DatHeader.FileAmount)
	DatHeader.SizesOffset = DatHeader.NamesOffset + (LongestFilename * DatHeader.FileAmount) + 4
	DatHeader.HashMapOffset = DatHeader.SizesOffset + (4 * DatHeader.FileAmount)
	
	var TempPos = DatHeader.HashMapOffset + StructSize + (2 * DatHeader.FileAmount)
	var startpad = CalcPadding(16, TempPos)
	
	var _pointer = TempPos + startpad

	
	for file in Files:
		offsets.append(_pointer)
		_pointer += len(file.Data)
		var pad = CalcPadding(16, (int)(_pointer))
		_pointer += pad
	var FileData = FileAccess.open(outputdir, FileAccess.WRITE)
	
	FileData.store_string('DAT')
	FileData.store_8(0)
	FileData.store_32(DatHeader.FileAmount)
	FileData.store_32(DatHeader.PositionsOffset)
	FileData.store_32(DatHeader.ExtensionsOffset)
	FileData.store_32(DatHeader.NamesOffset)
	FileData.store_32(DatHeader.SizesOffset)
	FileData.store_32(DatHeader.HashMapOffset)
	FileData.store_32(0)
	
	FileData.seek(DatHeader.PositionsOffset)
	for i in DatHeader.FileAmount:
		FileData.store_32(offsets[i])
	
	FileData.seek(DatHeader.ExtensionsOffset)
	for i in DatHeader.FileAmount:
		FileData.store_string(extensions[i])
		FileData.store_8(0) # If this doesnt work try changing this to store_8 '0' 

	FileData.seek(DatHeader.NamesOffset)
	FileData.store_32(LongestFilename)
	
	for i in DatHeader.FileAmount:
		FileData.store_string(names[i])
		for x in pad_string(names[i], LongestFilename):
			FileData.store_8(0)
	
	FileData.seek(DatHeader.SizesOffset)
	for i in DatHeader.FileAmount:
		FileData.store_32(sizes[i])
	
	FileData.seek(DatHeader.HashMapOffset)
	FileData.store_32(PrehashShift)
	FileData.store_32(16)
	FileData.store_32(16 + len(BucketOffsets) * 2)
	FileData.store_32(16 + (len(BucketOffsets) * 2) + (len(Hashes) * 4))
	
	for i in len(BucketOffsets):
		FileData.store_16(BucketOffsets[i])
		
	for i in DatHeader.FileAmount:
		FileData.store_32(Hashes[i])
	
	for i in DatHeader.FileAmount:
		FileData.store_16(Indices[i])
	
	var hashPad = CalcPadding(16, FileData.get_position());
	for i in hashPad:
		FileData.store_8(0)
	
	for i in DatHeader.FileAmount:
		if offsets[i] > FileData.get_length():
			var extend = offsets[i] - FileData.get_length()
			var j =0
			while j < extend:
				j+=1
				FileData.store_8(0)
		FileData.seek(offsets[i])
		FileData.store_buffer(Files[i].Data)
		
	FileData.close()
	var totalbytes = FileAccess.get_file_as_bytes(outputdir)
	var file_size_in_mb = len(totalbytes) * 1e-6
	if file_size_in_mb > 80:
		print("File over 80MB, this should never happen with SMU Embedded for WemKiller")
	
	return 1



	

	
