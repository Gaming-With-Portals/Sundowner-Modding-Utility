extends Control

var directory = ""
var files1 = []
var files2 = []

var array_1 = []
var array_2 = []
var array_2_data = []
var formatted_array_2 = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $dir_explorer_1.scroll_vertical == $dir_explorer_2.scroll_vertical:
		$dir_explorer_1.scroll_vertical = $dir_explorer_2.scroll_vertical
	

func _reset():
	for x in $dir_explorer_1/VBoxContainer.get_children():
		$dir_explorer_1/VBoxContainer.remove_child(x)
	for x in $dir_explorer_2/VBoxContainer.get_children():
		$dir_explorer_2/VBoxContainer.remove_child(x)
	$load.visible = true
	files2 = []
	files1 = []
	array_1 = []
	array_2 = []
	array_2_data = []
	formatted_array_2 = []
	$Timer.stop()

func _on_texture_button_pressed():
	var fd = Fileautoload.get_node("FileDialogDir")
	fd.clear_filters()
	fd.dir_selected.connect(_open_dir)
	fd.visible = true
	
	
func _open_dir(file):
	_reset()
	$load.visible = false
	print("Open dir " + file)
	print(DirAccess.get_files_at(file))
	
	files1 = DirAccess.get_files_at(file)
	directory = file
	var filearray = []
	for file2 in GlobalVariables.gv_files:
		filearray.append(file2)
		
	array_1 = []
	array_2 = []
	var fileincommon = false
	for i in files1:
		for o in filearray:
			if i == o.Name:
				array_1.append(i)
				array_2.append(o)
				fileincommon = true
	if not fileincommon:
		GlobalVariables.error("No files in common, the Dynamic Dat Repacker cannot do anything")
		$load.visible = true
	else:
		for x in array_2:
			formatted_array_2.append(x.Name)
		for x in array_2:
			array_2_data.append(x.Data)
		
		$dir_explorer_1/VBoxContainer._build_directory(array_1)
		$dir_explorer_2/VBoxContainer._build_directory(formatted_array_2)
		$Timer.start()


func _on_timer_timeout():
	print("Refresh")
	# Refresh
	var files_repacked = 0
	for x in range(len(array_1)):
		var item = GlobalVariables.gv_files.find(array_2[x])
		if FileAccess.get_file_as_bytes(directory + "\\" + array_1[x]) != GlobalVariables.gv_files[item].Data:
			print("File " + array_1[x] + " does not match. Rebuilding.")
			$dir_explorer_1/VBoxContainer.get_child(x).get_node("ap").play("anim_2")
			$dir_explorer_2/VBoxContainer.get_child(x).get_node("ap").play("anim")
			files_repacked+=1
			print("Item: " + str(item))
			GlobalVariables.gv_files[item].Data = FileAccess.get_file_as_bytes(directory + "\\" + array_1[x])
			DatHandler.Save(GlobalVariables.gv_files, GlobalVariables.dat_path)
			
			
			get_tree().current_scene.get_node("notif").get_node("notiftext").text = str(files_repacked) + " file(s) repacked!"
			get_tree().current_scene.get_node("global_anim_player").play("notification")
	$Timer.start()
