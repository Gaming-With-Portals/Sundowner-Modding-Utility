extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_tab_bar_tab_clicked(tab):
	if tab == 0:
		$TabBar.add_tab("New Tab")
		var instance = load("res://main.tscn").instantiate()
		$Control.add_child(instance)
		instance.tab_id = $TabBar.tab_count - 1
		print("Created tab with tab id: " + str(instance.tab_id))
	else:
		for x in $Control.get_children():
			if x.tab_id == tab:
				x.visible = true
			else:
				x.visible = false
