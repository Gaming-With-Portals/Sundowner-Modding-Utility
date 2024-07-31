extends Node2D

var file_bytes : PackedByteArray
var pointer = 0


func read_file(bytes : PackedByteArray):
	file_bytes = bytes
	pointer = 0

func read_u8():
	var temp = file_bytes.decode_u8(pointer) # Get Number
	pointer+=1 # Advance Pointer
	return temp
	
func read_u16():
	var temp = file_bytes.decode_u16(pointer) # Get Number
	pointer+=2 # Advance Pointer
	return temp

func read_u32():
	var temp = file_bytes.decode_u32(pointer) # Get Number
	pointer+=4 # Advance Pointer
	return temp
	
func read_u64():
	var temp = file_bytes.decode_u64(pointer) # Get Number
	pointer+=8 # Advance Pointer
	return temp

func get_bytes(length):
	var temp = file_bytes.slice(pointer, pointer + length)
	pointer+=length
	return temp

func read_string(length : int):
	var temp = file_bytes.slice(pointer, pointer + length).get_string_from_utf8()
	pointer+=length
	return temp
	
func read_string_array(length, array_length):
	var List = []
	for i in array_length:
		List.append(read_string(length))
	return List

func seek(pos : int):
	while len(file_bytes) < pos:
		file_bytes.append(0)
	pointer = pos

func write_file():
	file_bytes = []
	pointer = 0

func write_u8(number):
	file_bytes.append(0)
	file_bytes.encode_u8(pointer, number)
	pointer+=1

func write_u16(number):
	file_bytes.append_array([0, 0])
	file_bytes.encode_u16(pointer, number)
	pointer+=2
	
func write_u32(number):
	file_bytes.append_array([0, 0, 0, 0])
	file_bytes.encode_u32(pointer, number)
	pointer+=4

func write_u64(number):
	file_bytes.append_array([0, 0, 0, 0, 0, 0, 0, 0])
	file_bytes.encode_u64(pointer, number)
	pointer+=8
	
func write_string(string : String):
	var tmp = string.to_utf8_buffer()
	# Ensure there is enough space in file_bytes
	while file_bytes.size() < pointer + tmp.size():
		file_bytes.append(0)  # Add padding bytes if necessary
	for i in range(tmp.size()):
		file_bytes[pointer + i] = tmp[i]
	pointer += tmp.size()

func write_buffer(bytes : PackedByteArray):
	# Ensure there is enough space in file_bytes
	while file_bytes.size() < pointer + bytes.size():
		file_bytes.append(0)  # Add padding bytes if necessary

	for i in range(bytes.size()):
		file_bytes[pointer + i] = bytes[i]

	pointer += bytes.size()
