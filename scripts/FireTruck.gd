extends Area3D

@export var required_extinguishers: int = 3
@export var portal: Node3D # NEU: Hier ziehst du das Portal im Godot-Editor rein!


var delivered: int = 0
var delivered_list: Array = []

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	
	# Only count extinguishers
	if not body.is_in_group("extinguisher"):
		return
	
	# Prevent counting same one twice
	if body in delivered_list:
		return
	
	delivered_list.append(body)
	delivered += 1
	
	print("Delivered: ", delivered, "/", required_extinguishers)
	
	# Optional: remove extinguisher (Löscher verschwindet, wenn er im LKW landet)
	#body.queue_free()
	
	if delivered >= required_extinguishers:
		_win_level()

func _on_body_exited(body: Node) -> void:
		# Only count extinguishers
	if not body.is_in_group("extinguisher"):
		return
	
	# Prevent counting same one twice
	if body in delivered_list:
		delivered_list.erase(body)
		delivered -= 1
		print("Removed: ", delivered, "/", required_extinguishers)

func _win_level():
	print("YOU WIN 🎉")
	
	if portal:
		if portal.has_method("activate_portal"): # HIER
			portal.activate_portal()             # UND HIER
