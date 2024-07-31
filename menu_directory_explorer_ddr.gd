extends Control


func _build_directory(files):
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()
	
	var file_list = files
	
	var file_og = load("res://scenes/file_ddr.tscn")
	var x = 0
	for file in file_list:
		x+=1
		var FileThing = file_og.instantiate()
		FileThing._build_file(file, $FileList/VBoxContainer)
		self.add_child(FileThing)

