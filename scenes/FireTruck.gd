extends Node3D

@export var required_extinguishers: int = 3

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
	
	# Optional: remove extinguisher
	body.queue_free()
	
	if delivered >= required_extinguishers:
		_win_level()


func _win_level():
	print("YOU WIN 🎉")
	
	# Replace with your own win logic:
	# show UI
	# load next level
	# play sound
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://NextLevel.tscn")
