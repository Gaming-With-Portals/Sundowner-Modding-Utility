extends VBoxContainer

var tools_path = null
# Called when the node enters the scene tree for the first time.
func _ready():
	tools_path = OS.get_executable_path().get_base_dir() + "/pmc/"
	await get_tree().create_timer(0.1).timeout
	var settings_file2 = FileAccess.open(tools_path + "settings.smu", FileAccess.READ)
	# Settings stored in heirarchy order for now
	settings_file2.get_8()
	settings_file2.get_8()
	settings_file2.get_8()
	var count = settings_file2.get_8()
	settings_file2.close()
	
	if not FileAccess.file_exists(tools_path + "recents.smu"):
		var settings_file = FileAccess.open(tools_path + "recents.smu", FileAccess.WRITE)
		settings_file.close()
		
	var settings_file = FileAccess.open(tools_path + "recents.smu", FileAccess.READ)
	for x in range(count):
		var path = settings_file.get_line()
		if not path == "":
			var child = load("res://scenes/recent_file.tscn").instantiate()
			add_child(child)
			child._build_file(path.get_file(), path, get_tree().current_scene)
	
	
	settings_file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
