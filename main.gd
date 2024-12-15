extends Control

# This controls literally everything for no reason
var dir_tracker = ["main"]

var filePath:String
var LoadedFile = null
var FileType = ""
var tools_path = null
var data_path = null
var IsDatLoaded = false
var uuid = null
var file_objects = null # Base file objects
var VALID_EXTENSIONS = ["dat", "dtt", "evn", "eff", "eft"]
var RAW_CURRENT_FILE_NAME = ""
var REQUIRED_FILES_FOR_COMPILE = []
var ASSOCIATED_FILE_REF = null
var SETTINGS_RECENT_COUNT
var mg_executable_path = ""
var thread: Thread
var tab_id = 0

func _ready():
	tools_path = OS.get_executable_path().get_base_dir() + "/pmc/"
	data_path = OS.get_executable_path().get_base_dir() + "/pmc/data/"
	print("Clearing cache")
	_clear_temp_directory()
	print("Checking for updates...")
	#$HTTPRequest.request("https://api.github.com/repos/Gaming-With-Portals/Sundowner-Modding-Utility/releases")

	
	
	print(tools_path)
	# Connect the signals
	get_tree().get_root().files_dropped.connect(_getDroppedFiles)
	
	for child in $right_pane.get_children():
		child.visible = false
	$right_pane/menu_000.visible = true
	
	if not FileAccess.file_exists(tools_path + "settings.smu"):
		print("Creating settings file")
		var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.WRITE_READ)
		settings_file.store_8(0)
		settings_file.store_8(0)
		settings_file.store_8(0)
		settings_file.store_8(6)
		settings_file.store_pascal_string("")
		SETTINGS_RECENT_COUNT = 6
		settings_file.close()
	else:
		var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.READ)
		if number_to_bool(settings_file.get_8()):
			print("CFG - Force easy to read font")
		if number_to_bool(settings_file.get_8()):
			
			_basic_colors()
		if number_to_bool(settings_file.get_8()):
			print("CFG - Force disable VFX")
		SETTINGS_RECENT_COUNT = settings_file.get_8()
		mg_executable_path = settings_file.get_pascal_string()
		print("MG PATH: " + mg_executable_path)
		if not FileAccess.file_exists(mg_executable_path) and not mg_executable_path == "":
			GlobalVariables.error("Metal Gear Rising executable @ " + mg_executable_path + " no longer exists\nPlease update this")
			mg_executable_path = ""

	if not DirAccess.dir_exists_absolute("user://recompile/"):
		DirAccess.make_dir_absolute("user://recompile/")
	# Get arguments
	var args = OS.get_cmdline_args()
	print("ARGUMENTS: " + str(args))
	if len(args) >= 1 and not args[0].contains("tscn"):
		_getDroppedFiles(args)
	# Bind
	$toolbar/file.get_popup().id_pressed.connect(_file_menu_signal)
	$toolbar/view.get_popup().id_pressed.connect(_view_menu_signal)
	$toolbar/help.get_popup().id_pressed.connect(_help_menu_signal)
	if args.has("UPDATE_COMP"):
		print("Launched from update...")
		for x in DirAccess.get_files_at(OS.get_executable_path().get_base_dir()):
			if ".exe" in x:
				print("exec " + x)
				if OS.get_executable_path().get_base_dir() + "/" + x != OS.get_executable_path():
					print("Killing process.")
					OS.execute("taskkill", ["/im", x])
		OS.execute("taskkill", ["/f", "/im", "xcopy.exe"])
		var output = []
		await get_tree().create_timer(1).timeout
		for x in DirAccess.get_files_at(OS.get_executable_path().get_base_dir()):
			if ".exe" in x:
				print("exec: " + x)
				OS.execute("del", [OS.get_executable_path().get_base_dir() + "/" + x])
	
func _basic_colors():
	print("CFG - Force simple color interface")
	$bg/bg_001.visible = false
	$bg/CPUParticles2D.visible = false
	$bg/TextureRect2.visible = false
	for x in GetAllTreeNodes():
		if x.name.contains("divider"):
			x.color = Color(0.3, 0.3, 0.3)
			
func update_directory_path(files, path, fileref):
	ASSOCIATED_FILE_REF = fileref
	RAW_CURRENT_FILE_NAME = path
	if $right_pane/menu_directory_explorer/directory.text == filePath.get_file() + "://":
		$right_pane/menu_directory_explorer/dir_anim_player.play("directory_back")
		for x in $right_pane/menu_directory_explorer/FileList/VBoxContainer.get_children():
			x.reparent($right_pane/menu_directory_explorer/gui_storage_000)

	$right_pane/menu_directory_explorer/directory.text = filePath.get_file() + "://" + path

	
	GlobalVariables.gv_files = files
	$right_pane/menu_directory_explorer._build_directory(self)
	$right_pane/menu_ddr.init_dat()




func _clear_temp_directory():
	var output = []
	print(OS.get_user_data_dir() + "/recompile/")
	for file in DirAccess.get_files_at(OS.get_user_data_dir() + "/recompile/"):
		OS.execute("rm", ["-f", "-r", "-v", OS.get_user_data_dir() + "/recompile/" + file], output)
		print(output)
		
	for file in DirAccess.get_files_at(OS.get_user_data_dir() + "/"):
		OS.execute("rm", ["-f", "-r", "-v", OS.get_user_data_dir() + "/" + file], output)

	print(output)
	
func set_file_preview(filename):
	$file.text = filename

func GetAllTreeNodes(node = get_tree().root, listOfAllNodesInTree = []):
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree

func _getDroppedFiles(files):
	if not IsDatLoaded:
		var start_time = Time.get_ticks_msec()
		print(files)
		if len(files) > 1:
			var file_extensions = []
			
		else:
			filePath = files[0]
			var extension = filePath.get_extension()
			print(extension)
			if VALID_EXTENSIONS.has(extension.to_lower()):
				$right_pane/menu_000/Label.text = "[center]Loading, please wait[/center]"
				await get_tree().create_timer(0.1).timeout
				print("LOADING FILES")
				file_objects = DatHandler.Load(filePath)
				$toolbar/view.get_popup().add_item("Directory Explorer (F4)")
				$toolbar/view.get_popup().add_item("Dynamic Data Repacker (F5)")
				print("TYPE: " + str(typeof(GlobalVariables.gv_files)))
				print("DONE LOADING")
				GlobalVariables.gv_files = file_objects
				GlobalVariables.dat_path = filePath
				$right_pane/menu_directory_explorer/directory.text = filePath.get_file() + "://"
				$right_pane/menu_directory_explorer.visible = true
				GlobalVariables.last_directory = "main"
				$right_pane/menu_directory_explorer._build_directory(self, "main")
				$right_pane/menu_000.visible = false

				IsDatLoaded = true

				$datinfo.text = "[center][color=#FF0000]| FILE NAME |[/color]\n" + filePath.get_file() + "\n[color=#FF0000]| FILE COUNT |[/color]\n" + str(len(file_objects))
				# Add size
				$datinfo.text = $datinfo.text + "[center][color=#FF0000]| FILE SIZE |[/color]\n" + str((round(len(FileAccess.get_file_as_bytes(filePath)) * 1e-6 * 1000.0)) / 1000.0) + "mb"
				# Add asc.
				var assocation_file_text = FileAccess.get_file_as_string(tools_path + "dat_info.smu_dat")
				var assocation_file_lines = assocation_file_text.rsplit("\r", true, -1)

				for x in assocation_file_lines:
					var tmp_string = x.replace("\r", "")
					tmp_string = tmp_string.replace("-", "")
					tmp_string = tmp_string.rsplit(": ", true, -1)
					
					if filePath.get_file().get_basename() == tmp_string[0]:
						print("File association: " + tmp_string[1])
						$datinfo.text = $datinfo.text + "[center][color=#FF0000]| FILE IN-GAME USE |[/color]\n" + tmp_string[1]
						break
				
				
				
				
				
				$right_pane/menu_000/Label.text = "[center]File already loaded\nDeload file to access this menu[/center]"
				var end_time = Time.get_ticks_msec()
				print("TOTAL TIME: " + str(end_time - start_time) + "ms")
				FileType = extension
				
				var settings_file = FileAccess.open(tools_path + "recents.smu", FileAccess.READ)
				var string_array = []
				for x in range(SETTINGS_RECENT_COUNT):
					var line = settings_file.get_line()
					if not line == "":
						string_array.append(line)
				
				settings_file = FileAccess.open(tools_path + "recents.smu", FileAccess.WRITE)
				settings_file.store_string(filePath + "\n")
				for x in range(string_array.size()):
					settings_file.store_string(string_array[x] + "\n")
				settings_file.close()
				


			elif extension == "smu_dat":
				print("UPDATING INTERNAL DATA")
				var entries_added = 0
				var input = FileAccess.open(filePath, FileAccess.READ)
				var output = FileAccess.open(tools_path + "dat_info.smu_dat", FileAccess.READ_WRITE)
				var out_text = output.get_as_text()
				var inp_text = input.get_as_text()
				var inp_lines = inp_text.rsplit("\n", true, -1)
				var entries_to_add = []
				
				for line in inp_lines:
					if not line in out_text:
						print("NEW FILE DETECTED: " + line)
						entries_added+=1
						entries_to_add.append(line)
				output.store_string(out_text + "\n")
				for entry in entries_to_add:
					output.store_string(entry)
						
				$global_anim_player.play("notification")
				$notif/notiftext.text = "Added " + str(entries_added) + " assocations!"
			elif extension == "smu_update":
				print("Sundowner Mod Tool Update")
				GlobalVariables.updating = true
				GlobalVariables.update_file_path = filePath
				get_tree().change_scene_to_file("res://auto-updater.tscn")
				
	else:
				var file_og = load("res://scenes/file.tscn")
				var data_og = load("res://scenes/structs/DatFileEntry.gd")
				print("Import file(s) " + str(files))
				for x in files:
					print("IMPORTING FILE: " + str(x))
					var FileThing = file_og.instantiate()
					var file_data = data_og.new()
					
					file_data.Data = FileAccess.get_file_as_bytes(x)
					file_data.Name = x.get_file()
					
					
					FileThing._build_file(file_data, $FileList, self)
					FileThing.is_saved = false

					
					GlobalVariables.gv_files.append(FileThing.File)
					$right_pane/menu_directory_explorer/FileList.get_node(GlobalVariables.current_dir).add_child(FileThing)

func _build_file_info(uuid, file):
	$datinfo.text = "FILE INFO:\nType:\n." + FileType + "\nName:\n" + file.get_file()
	


		
func _process(delta):
	var title_info = ""
	if not IsDatLoaded:
		title_info = " - NO FILE LOADED"
	else:
		title_info = " - " + filePath.get_file()
		
	DisplayServer.window_set_title("Sundowner Modding Utility" + title_info + " - " + str(int(Engine.get_frames_per_second())) + " FPS")


func _on_file_pressed():

	DatHandler.Save(GlobalVariables.gv_files, filePath)
	$global_anim_player.play("notification")
	$notif/notiftext.text = "SAVED"
	
	
func number_to_bool(num):
	if num == 1:
		return true
	elif num == 0:
		return false
		
func bool_to_num(inp):
	if inp:
		return 1
	else:
		return 0

func _on_settings_pressed():
	for child in $right_pane.get_children():
		child.visible = false
	$right_pane/menu_settings.visible = true
	
	var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.READ)
	# Settings stored in heirarchy order for now
	$right_pane/menu_settings/VBoxContainer/forceeasy.button_pressed = number_to_bool(settings_file.get_8())
	$right_pane/menu_settings/VBoxContainer/simplecolors.button_pressed = number_to_bool(settings_file.get_8())
	$right_pane/menu_settings/VBoxContainer/disablevfx.button_pressed = number_to_bool(settings_file.get_8())
	$right_pane/menu_settings/VBoxContainer/HBoxContainer/LineEdit.text = str(settings_file.get_8())
	
	# Make sure this stays here so no memory leaks :D 
	settings_file.close()
	


func _on_directory_pressed():
	if IsDatLoaded:
		for child in $right_pane.get_children():
			child.visible = false
		$right_pane/menu_directory_explorer.visible = true

func _on_view_pressed():
	if $view_drop_down.visible == false:
		$view_drop_down.visible = true
	else:
		$view_drop_down.visible = false


func _on_save_pressed():
	print("saving")
	var settings_file = FileAccess.open(tools_path + "settings.smu", FileAccess.WRITE_READ)
	# Settings stored in heirarchy order for now
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/forceeasy.button_pressed))
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/simplecolors.button_pressed))
	settings_file.store_8(bool_to_num($right_pane/menu_settings/VBoxContainer/disablevfx.button_pressed))
	settings_file.store_8(SETTINGS_RECENT_COUNT)
	settings_file.store_pascal_string(mg_executable_path)
	
	# Make sure this stays here so no memory leaks :D 
	settings_file.close()

	if not IsDatLoaded:
		get_tree().change_scene_to_file("res://main.tscn")

func _input(event):
	if event.is_action_pressed("Save"):
		_on_file_pressed()
	if event.is_action_pressed("SaveAs"):
		if IsDatLoaded:
			print("SAVE AS")
			var fd = Fileautoload.get_node("FileDialogExp")
			fd.clear_filters()
			fd.add_filter("*."+FileType, "MGRR Data File")
			fd.file_selected.connect(_save_as_file)
			fd.visible = true
		else:
			GlobalVariables.error("File must be open before saving")
		
	if Input.is_key_pressed(KEY_F2):
		_view_menu_signal(1)
	if Input.is_key_pressed(KEY_F3):
		_view_menu_signal(2)
	if Input.is_key_pressed(KEY_F4):
		_view_menu_signal(3)
	if Input.is_key_pressed(KEY_F1):
		_help_menu_signal(0)

func _on_file_info_button_down():
	var ext = $file.text.get_extension()
	var JSONDATA = FileAccess.open("res://assets/data.json", FileAccess.READ)
	var data = JSON.parse_string(JSONDATA.get_as_text())
	if data.has(ext):
		OS.alert(data[ext]["desc"], "SMU: FILE INFO")
	else:
		GlobalVariables.error("This file extension is not recognized")
	

func _on_load_pressed():
	for child in $right_pane.get_children():
		child.visible = false
	$right_pane/menu_000.visible = true


func _on_directory_back_pressed():

	_change_dir("main")
	
	


func _on_line_edit_text_changed(new_text):
	var text = int(new_text)
	if text > 20:
		GlobalVariables.error("Recent counts over 20 are generally not recommened.\nThis will still save just beware")
	print(text)
	SETTINGS_RECENT_COUNT = text


func _on_reload_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _file_menu_signal(id):
	match id:
		5:
			if IsDatLoaded:
				_on_file_pressed()
			else:
				GlobalVariables.error("File must be open before saving")		
		1:
			if IsDatLoaded:
				print("SAVE AS")
				var fd = Fileautoload.get_node("FileDialogExp")
				fd.clear_filters()
				fd.add_filter("*."+FileType, "MGRR Data File")
				fd.file_selected.connect(_save_as_file)
				fd.visible = true
			else:
				GlobalVariables.error("File must be open before saving")
		
		2:
			var fd = Fileautoload.get_node("FileDialog")
			fd.clear_filters()
			fd.add_filter("*.dat, *.dtt, *.eff", "MGRR Container File")

			fd.file_selected.connect(_load_file_from_menu)
			fd.visible = true
		3:
			get_tree().quit()
		6:
			print(mg_executable_path)
			thread = Thread.new()
			thread.start(_launch_mgr.bind(mg_executable_path))
		7:
			get_tree().change_scene_to_file("res://main.tscn")
			

func _launch_mgr(userdata):
	OS.execute(userdata, [], [], false)

func _load_file_from_menu(file):
	var array = []
	array.append(file)
	_getDroppedFiles(array)


func _save_as_file(dir):
	DatHandler.Save(GlobalVariables.gv_files, dir)

func _help_menu_signal(id):
	match id:
		0:
			$AboutWindow.visible = true
		1:
			OS.shell_open(tools_path + "docs.html")

func _view_menu_signal(id):
	$global_anim_player.play("menu_change")
	await get_tree().create_timer(0.2).timeout
	for child in $right_pane.get_children():
		child.visible = false;

	match id:
		1:
			$right_pane/menu_settings.visible = true
		2:
			$right_pane/menu_000.visible = true
		3:
			$right_pane/menu_directory_explorer.visible = true
		4:
			$right_pane/menu_ddr.visible = true
			
			
func _on_select_dir_mgr_button_down():
	$right_pane/menu_settings/VBoxContainer/mgrdir/FileDialog.visible = true


func _on_file_dialog_file_selected(path):
	print(path)
	mg_executable_path = path


func _on_button_button_down():
	
	OS.shell_open(tools_path + "docs.html")

func _add_dir_passthrough(files, dirname):
	
	$right_pane/menu_directory_explorer._add_directory(self, files, dirname)

func _change_dir(new_dir):
	dir_tracker.append(new_dir)
	$global_anim_player.play("dir_change")
	await get_tree().create_timer(0.2).timeout
	if new_dir == "main":
		dir_tracker = ["main"]
		$right_pane/menu_directory_explorer/directory.text == filePath.get_file() + "://"
	else:
		$right_pane/menu_directory_explorer/directory.text == new_dir + "://"
	
	new_dir = new_dir.replace(".", "_")
	GlobalVariables.current_dir = new_dir
	print("Changing to " + new_dir)
	
	for x in $right_pane/menu_directory_explorer/FileList.get_children():
		if x.name == new_dir:
			x.visible = true
		else:
			x.visible = false
		


func _on_view_button_down():
	pass # Replace with function body.


func _on_http_request_request_completed(result, response_code, headers, body):
	var data = body.get_string_from_utf8()
	var json = JSON.new()
	var error = json.parse(data)
	if error == OK:
		if len(json.data[0]["tag_name"].split("_")) > 1:
			var tag_id = json.data[0]["tag_name"].split(".")[1]
			tag_id = int(tag_id)
			if (tag_id > GlobalVariables.APP_VERSION):
				$global_anim_player.play("notification")
				$notif/notiftext.text = "SAVED"
		
		else:
			print("Unable to determine latest version")


func _on_get_file_request_completed(result, response_code, headers, body):
	print("Got file info")
	var data = body.get_string_from_utf8()
	var json = JSON.new()
	var error = json.parse(data)
	
	GlobalVariables.update_url = json.data['browser_download_url']
	print("Prompt update")




func _on_update_diag_confirmed():
	pass
	#get_tree().change_scene_to_file("res://auto-updater.tscn")
