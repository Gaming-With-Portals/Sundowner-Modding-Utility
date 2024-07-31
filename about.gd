extends Button
var aboutwin = preload("res://about_window.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	print("Open about")
	var d = aboutwin.instantiate()
	add_child(d)
	d.visible = true
	d.title = "ABOUT: Metal Gear Rising: Sundowner Mod Utility"

