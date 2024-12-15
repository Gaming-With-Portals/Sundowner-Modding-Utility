extends Node

var applic_name = "MGRR: Sundowner Modding Utility"
var menu_state = 0
@export var gv_files : Array
@export var file_blacklist : Array
var illegal_characters = ["#", "%", "{", "}", "\\", "<", ">", "*", "?", "/", " ", "$", "!", "'", '"', ":", "@", "+", "'", "|", "="]
var animation_icon
var texture_icon
var bin_icon
var dat_icon
var bnk_icon
var misc_icon
var model_icon
var bxm_icon
var dat_path
var est_icon
var f_servo_icon
var updating = false
var update_file_path = ''
var F_SERVO_CONFIGURED = false
var F_SERVO_PATH = "F:\\Downloads\\F-SERVO_v1.4.3\\F-SERVO.exe"
var F_SERVO_EXTENSIONS = ["bnk", "est"]
var update_url = ""
var replacing_file = false

@export var last_directory : String
var file_system
var current_dir

var APP_VERSION = 2

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	var pp := node as Popup
	
	if pp:
		pp.transparent_bg = true

func _ready():
	print("Loading icons")
	animation_icon = load("res://assets/icons/animation.png")
	texture_icon = load("res://assets/icons/texture.png")
	bin_icon =  load("res://assets/icons/bin.png")
	dat_icon = load("res://assets/icons/dat.png")
	bnk_icon = load("res://assets/icons/bnk.png")
	misc_icon = load("res://assets/icons/misc.png")
	model_icon = load("res://assets/icons/model.png")
	bxm_icon = load("res://assets/icons/bxm.png")
	est_icon = load("res://assets/icons/est.png")
	f_servo_icon = load("res://assets/icons/f-servo.png")

func error(message):
	var audiohandler = AudioStreamPlayer2D.new()
	get_tree().current_scene.add_child(audiohandler)
	if randi_range(0, 100000) == 1:
		audiohandler.stream = load("res://assets/ninja.mp3")
	else:
		audiohandler.stream = load("res://assets/denied.wav")
		
	audiohandler.play()
	OS.alert(message, applic_name)
