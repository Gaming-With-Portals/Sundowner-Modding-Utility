extends Control

@onready var range1 = $bg_001
@onready var range2 = $TextureRect2
var xenon_dfps = null
var range1_dfps = null
var range2_dfps = null
var range3_dfps = null
var sun_dfps = null
# Called when the node enters the scene tree for the first time.
func _ready():
	range1_dfps = range1.position
	range2_dfps = range2.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouseposx = get_viewport().get_mouse_position().x
	var mouseposy = get_viewport().get_mouse_position().y

	range1.position.x = (mouseposx / 600) + range1_dfps.x
	range1.position.y = (mouseposy / 600) + range1_dfps.y
	range2.position.x = (mouseposx / 200) + range2_dfps.x
	range2.position.y = (mouseposy / 200) + range2_dfps.y
