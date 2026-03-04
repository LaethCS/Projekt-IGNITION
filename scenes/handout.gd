extends Control

func _ready():
	# Maus sichtbar machen, damit man den Button klicken kann
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_zurück_button_pressed():
		get_tree().change_scene_to_file("res://scenes/levelMenu.tscn")
