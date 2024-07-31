extends Control
var path = ''
var tools_path = ""
var update_path
# Called when the node enters the scene tree for the first time.
func _ready():
	var version = GlobalVariables.APP_VERSION
	print("VERSION: " + str(version))
	tools_path = OS.get_executable_path().get_base_dir() + "/pmc/"
	update_path = OS.get_executable_path().get_base_dir()
	$status.text = "Initalizing"
	if GlobalVariables.updating == true:
		path = GlobalVariables.update_file_path
	else:
		OS.crash("Critical update error")
		pass
		
	await get_tree().create_timer(1.0).timeout
	$status.text = "Extracting files..."
	$bar.value = 25
	var output = []
	print(path)
	OS.execute("cmd.exe", ["tar -xf", path, "--directory", tools_path + 'tmp_update/'], output)
	await get_tree().create_timer(0.3).timeout
	print(str(output))
	$status.text = "Replacing files... (the application will restart)"
	$bar.value = 75
	await get_tree().create_timer(1.0).timeout
	output = []
	DirAccess.copy_absolute(tools_path + "tmp_update/MetalGearDesperadoModdingUtility.exe", update_path + "/MetalGearDesperadoModdingUtility_v" + str(version) + ".exe")
	$status.text = "Finalizing..."
	$bar.value = 90
	get_tree().root.mode = Window.MODE_MINIMIZED
	await get_tree().create_timer(0.2).timeout
	OS.execute(update_path + "/MetalGearDesperadoModdingUtility_v" + str(version) + ".exe", [])
	get_tree().quit()



	
