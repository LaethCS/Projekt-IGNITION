extends Node3D

@export var required_extinguishers: int = 3
@export var portal: Node3D # NEU: Hier ziehst du das Portal im Godot-Editor rein!

@onready var delivery_zone: Area3D = $DeliveryZone

var delivered: int = 0
var delivered_list: Array = []

func _ready():
	delivery_zone.body_entered.connect(_on_body_entered)

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
	body.queue_free()
	
	if delivered >= required_extinguishers:
		_win_level()


func _win_level():
	print("YOU WIN 🎉")
	
	if portal:
		if portal.has_method("activate_portal"): # HIER
			portal.activate_portal()             # UND HIER
