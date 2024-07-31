extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var byte_array : PackedByteArray = []
	byte_array.append(0)
	byte_array.encode_u8(0, 25)
	print(str(byte_array))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
