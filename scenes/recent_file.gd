extends Control

var Path = null
var MainRef = null
var hover = false
func _build_file(text, path, main):
	$Label.text = text
	Path = path
	MainRef = main

func _on_info_pressed():
	if FileAccess.file_exists(Path):
		MainRef._getDroppedFiles([Path])
	else:
		GlobalVariables.error("This file no longer exists.")

func _input(ev):
	if hover:
		if ev is InputEventMouseButton and ev.is_pressed():
			if ev.double_click:
				print("Open")
				if FileAccess.file_exists(Path):
					MainRef._getDroppedFiles([Path])
				else:
					GlobalVariables.error("This file no longer exists.")


func _on_color_rect_mouse_entered():
	hover = true
	$ColorRect.color = "3a00008f"

func _on_color_rect_mouse_exited():
	hover = false
	$ColorRect.color = "0000008f"
