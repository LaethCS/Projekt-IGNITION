extends Area3D

# --- CONFIG ---
@export var wind_direction: Vector3 = Vector3(0, 0, -1) # Default: blowing along -Z
@export var wind_strength: float = 1.0      # Optional: intensity

func _ready() -> void:
	# Make sure the Area detects bodies
	monitoring = true
	monitorable = true
