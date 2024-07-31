extends Control
var thread_1: Thread
var threads = []
func _start():
	set_physics_process(false)
	$FileList/container.queue_free()

func _build_directory(mainGDref, directory):
	GlobalVariables.current_dir = "main"
	thread_1 = Thread.new()
	$Label3.visible = true
	$TextureRect.visible = true

	var vbox = VBoxContainer.new()
	for file in GlobalVariables.gv_files:
		var tmp_file = load("res://scenes/file.tscn").instantiate()
		tmp_file._build_file(file, $FileList, mainGDref)
		vbox.add_child(tmp_file)
	$FileList.add_child(vbox)
	vbox.name = "main"
	$TextureRect.visible = false
	$Label3.visible = false
	$search.visible = true

func _add_directory(mainGDref, files, dirname):
	print("Adding directory " + dirname + " with " + str(len(files)) + " file(s)")
	var vbox = VBoxContainer.new()
	for file in files:
		var tmp_file = load("res://scenes/file.tscn").instantiate()
		tmp_file._build_file(file, $FileList, mainGDref)
		vbox.add_child(tmp_file)
	$FileList.add_child(vbox)
	vbox.name = dirname
	vbox.visible = false

func break_array_into_4(array):
	var array1 = []
	var array2 = []
	var array3 = []
	var array4 = []
	var array_turn = 0
	for x in array:
		if array_turn == 0:
			array1.append(x)
			array_turn = 1
		elif array_turn == 1:
			array2.append(x)
			array_turn = 2
		elif array_turn == 2:
			array3.append(x)
			array_turn = 3
		elif array_turn == 3:
			array4.append(x)
			array_turn = 0
	return [array1, array2, array3, array4]


func _on_search_text_changed(new_text):
	
	$TextureRect.visible = true
	var node = $FileList.get_node(GlobalVariables.current_dir)
	
	if not new_text == "":
		for thing in node.get_children():
			if not new_text.to_lower() in thing.displayname.to_lower():
				if thing.visible == true:
					thing.get_node("AnimationPlayer").play("fade")
			else:
				if thing.visible == false:
					thing.get_node("AnimationPlayer").play_backwards("fade")
	else:
		for thing in node.get_children():
			if thing.visible == false:
				thing.get_node("AnimationPlayer").play_backwards("fade")
	
	$TextureRect.visible = false

func _physics_process(delta):
	$TextureRect.rotation += 10 * delta
	if $FileList.get_child_count() > 0:
		$Label2.text = ("FILE COUNT: " + str($FileList.get_node(GlobalVariables.current_dir).get_child_count()))
	pass


func _on_search_timer_timeout():
	pass # Replace with function body.
