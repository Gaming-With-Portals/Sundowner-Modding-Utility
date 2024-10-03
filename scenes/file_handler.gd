extends Control

var File = null
var vBox_ref = null
var mainscriptref = null
@export var displayname = ""
var ext = "smudat"
var IsContainer = false
var ContainedFiles = []
var hover = false
var parent = ""
var is_saved = true

func _ready():

	$pane000.visible = true
	$pane001.visible = false

		
func _build_file(file, vboxref, main):
	vBox_ref = vboxref
	mainscriptref = main
	File = file
	displayname = file.Name.get_file()
	if len(displayname) > 40:
		displayname = displayname.substr(0, 40) + "..."
		print("OVERFLOW")
	$pane000/Label.text = displayname
	ext = file.Name.get_extension()
	if ext == "mot":
		$pane000/TextureRect.texture = GlobalVariables.animation_icon
	elif ext == "wta" or ext == "wtp":
		$pane000/TextureRect.texture = GlobalVariables.texture_icon
	elif ext == "bxm":
		$pane000/TextureRect.texture = GlobalVariables.bxm_icon
	elif ext == "dat" or ext == "dtt" or ext == "env" or ext == "eff" or ext == "evn":
		$pane000/TextureRect.texture = GlobalVariables.dat_icon
		IsContainer = true
	elif ext == "bnk":
		if GlobalVariables.F_SERVO_CONFIGURED:
			$pane000/TextureRect.texture = GlobalVariables.f_servo_icon
			$pane000/TextureRect.material = null
		else:
			$pane000/TextureRect.texture = GlobalVariables.bnk_icon
	elif ext == "bin":
		$pane000/TextureRect.texture = GlobalVariables.bin_icon
	elif ext == "wmb":
		$pane000/TextureRect.texture = GlobalVariables.model_icon
	elif ext == "est":
		if GlobalVariables.F_SERVO_CONFIGURED:
			$pane000/TextureRect.texture = GlobalVariables.f_servo_icon
			$pane000/TextureRect.material = null
		else:
			$pane000/TextureRect.texture = GlobalVariables.est_icon
		
	else:
		$pane000/TextureRect.texture = load("res://assets/icons/misc.png")
	
	var file_size = len(File.Data) * 1e-6
	if file_size < 0.1:
		file_size = len(File.Data) / 1000.0
		$pane000/Size.text = str(int(file_size * 100) / 100.0) + "KB"
	else:
		$pane000/Size.text = str(int(file_size * 100) / 100.0) + "MB"
	

func _process(delta):
	if is_saved:
		$pane000/Label.text = displayname
	else:
		$pane000/Label.text = displayname + "*"

func _on_info_pressed():

	$pane000.visible = false
	$pane001.visible = true
	$mouse_det.visible = false


func _on_back_pressed():
	$pane000.visible = true
	$pane001.visible = false
	$mouse_det.visible = true

func _on_export_pressed():
	pass # Replace with function body.


func _on_replace_pressed():
	if not GlobalVariables.replacing_file:
		GlobalVariables.replacing_file = true
		var fd = Fileautoload.get_node("FileDialog")
		fd.clear_filters()
		fd.file_selected.connect(_replace_file)
		fd.visible = true
	

func _on_remove_pressed():
	var output = []
	var idx = GlobalVariables.gv_files.find(File)
	GlobalVariables.gv_files.remove_at(idx)
	self.queue_free()

func _on_rename_button_down():
	$pane_rename/LineEdit.text = File.Name
	$pane000.visible = false
	$mouse_det.visible = false
	$pane_rename.visible = true


func _replace_file(path):
	print(path)
	var fd = Fileautoload.get_node("FileDialog")
	fd.file_selected.disconnect(_replace_file)
	var file_data = FileAccess.open(path, FileAccess.READ)
	var file_byte = file_data.get_buffer(file_data.get_length())
	var idx = GlobalVariables.gv_files.find(File)
	GlobalVariables.gv_files[idx].Data = file_byte

	var file_size = len(GlobalVariables.gv_files[idx].Data) * 1e-6
	if file_size < 0.1:
		file_size = len(GlobalVariables.gv_files[idx].Data) / 1000.0
		$pane000/Size.text = str(int(file_size * 100) / 100.0) + "KB"
	else:
		$pane000/Size.text = str(int(file_size * 100) / 100.0) + "MB"
	GlobalVariables.replacing_file = false

func _export_file(path):
	
	var idx = GlobalVariables.gv_files.find(File)
	var path_f = path
	print("path: " + path_f + " extension: " + path_f.get_extension())
	if path_f.get_extension() == "":
		path_f = path + "." + GlobalVariables.gv_files[idx].Name.get_extension()

	var file_data = FileAccess.open(path_f, FileAccess.WRITE)
	file_data.store_buffer(File.Data)
	file_data.close()





func _on_mouse_det_mouse_entered():
	var idx = GlobalVariables.gv_files.find(File)
	mainscriptref.set_file_preview(GlobalVariables.gv_files[idx].Name)
	$pane000/ColorRect.color = "3a00008f"
	hover = true

func _on_mouse_det_mouse_exited():
	$pane000/ColorRect.color = "0000008f"
	hover = false
	
	
func _input(ev):

	
	if hover:
					
		if ev.is_action_released("right_click"):
			$RightClickContext.position = get_global_mouse_position()
			print("Mouse Y: " + str(get_global_mouse_position().y))
			if get_global_mouse_position().y > 520:
				$RightClickContext.position.y = 500
			$RightClickContext.position.x -= 10

			if $RightClickContext.visible:
				$RightClickContext.visible = false
				$pane000/Label.modulate = Color(1, 1 ,1)
			else:
				$RightClickContext.visible = true
				$pane000/Label.modulate = Color(1, 0 ,0)
	else:
		if ev.is_action_pressed("left_click") or ev.is_action_pressed("right_click"):
			await get_tree().create_timer(0.1).timeout
			$pane000/Label.modulate = Color(1, 1 ,1)
			$RightClickContext.visible = false


func _on_line_edit_text_submitted(new_text):
	var can_name = true
	for x in GlobalVariables.illegal_characters:
		if new_text.contains(x):
			GlobalVariables.error("Cannot have character '" + x + "' in a Windows filename")
			can_name = false
			break
	
	if can_name:
		$mouse_det.visible = true
		var idx = GlobalVariables.gv_files.find(File)
		if new_text.contains(GlobalVariables.gv_files[idx].Name.get_extension()):
			print("SET FILENAME: " + new_text)
			GlobalVariables.gv_files[idx].Name = new_text
			$pane000.visible = true
			$pane_rename.visible = false
			displayname = GlobalVariables.gv_files[idx].Name.get_file()
			$pane000/Label.text = displayname
		else:
			GlobalVariables.error("Changing the extension of this file is not recommended.\nYou can disable this error from settings")


func _on_export_button_down():
	var fd = Fileautoload.get_node("FileDialogExp")
	fd.clear_filters()
	var idx = GlobalVariables.gv_files.find(File)
	fd.add_filter("*." + File.Name.get_extension(), "SMU Suggested Output")
	fd.file_selected.connect(_export_file)
	fd.visible = true
