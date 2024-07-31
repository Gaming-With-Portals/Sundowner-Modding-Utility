extends Control

var File = null
var vBox_ref = null
var mainscriptref = null
var Folder = false
@export var displayname = ""
var ext = "smudat"

func _ready():

	$pane000.visible = true
	$pane001.visible = false

		
func _build_file(file, vboxref):
	vBox_ref = vboxref
	File = file
	displayname = file.get_file()
	if len(displayname) > 21:
		displayname = displayname.substr(0, 19) + "..."
		print("OVERFLOW")
	$pane000/Label.text = displayname
	ext = file.get_extension()
	if ext == "mot":
		$pane000/TextureRect.texture = GlobalVariables.animation_icon
	elif ext == "wta" or ext == "wtp":
		$pane000/TextureRect.texture = GlobalVariables.texture_icon
	elif ext == "bxm":
		$pane000/TextureRect.texture = GlobalVariables.bin_icon
	elif ext == "dat" or ext == "dtt" or ext == "env" or ext == "eff" or ext == "eft":
		$pane000/TextureRect.texture = GlobalVariables.dat_icon
		Folder = true
	elif ext == "bnk":
		$pane000/TextureRect.texture = GlobalVariables.bnk_icon
	elif ext == "bin":
		$pane000/TextureRect.texture = GlobalVariables.bin_icon
	elif ext == "wmb":
		$pane000/TextureRect.texture = GlobalVariables.model_icon
	else:
		$pane000/TextureRect.texture = load("res://assets/icons/misc.png")
