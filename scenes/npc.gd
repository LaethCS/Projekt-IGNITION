extends CharacterBody3D

# ----------------------
# CONFIG
# ----------------------
@export var move_speed: float = 3.5
@export var spray_range: float = 5.0

# ----------------------
# STATE
# ----------------------
var extinguisher: Node = null
var target_fire: Node = null
var state: String = "IDLE"

# ----------------------
# NODES
# ----------------------
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var pickup_detector: Area3D = $PickupDetector

func _ready():
	pickup_detector.body_entered.connect(_on_pickup_detector_entered)

# --- PICKUP DETECTOR SIGNAL ---
func _on_pickup_detector_entered(body: Node) -> void:
	# Only pick up if NPC does not have one
	if extinguisher:
		return

	if body.is_in_group("extinguisher"):
		print(body)
		# Call the existing method
		give_extinguisher(body)

# ----------------------
# MAIN LOOP
# ----------------------
func _physics_process(delta):
	match state:
		"IDLE":
			if extinguisher:
				_find_fire()
		"MOVE_TO_FIRE":
			_move_to_target(delta)
		"EXTINGUISH":
			_use_extinguisher(delta)

# ----------------------
# GIVE EXTINGUISHER TO NPC
# ----------------------
func give_extinguisher(fire_extinguisher: Node) -> void:
	extinguisher = fire_extinguisher
	extinguisher.pick_up(self) # use the existing holder system
	state = "IDLE"

# ----------------------
# FIRE SEARCH
# ----------------------
func _find_fire():
	var fires = get_tree().get_nodes_in_group("fire")
	if fires.is_empty():
		return

	# pick first alive fire
	for f in fires:
		if f and not f.is_dead:
			target_fire = f
			break

	if target_fire:
		nav.target_position = target_fire.global_transform.origin
		state = "MOVE_TO_FIRE"

# ----------------------
# MOVEMENT
# ----------------------
func _move_to_target(delta):
	if not target_fire or target_fire.is_dead:
		state = "IDLE"
		return

	var distance = global_transform.origin.distance_to(target_fire.global_transform.origin)
	if distance <= spray_range:
		state = "EXTINGUISH"
		return

	nav.target_position = target_fire.global_transform.origin
	var next_pos = nav.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	velocity = dir * move_speed
	move_and_slide()

# ----------------------
# USE EXTINGUISHER
# ----------------------
func _use_extinguisher(delta):
	if not target_fire or target_fire.is_dead:
		_stop_extinguisher()
		state = "IDLE"
		return

	# Face the fire
	look_at(target_fire.global_transform.origin, Vector3.UP)

	# Call the existing spray method from extinguisher
	if extinguisher.has_method("start_spraying"):
		extinguisher.start_spraying()

	# Move slightly closer if needed
	var distance = global_transform.origin.distance_to(target_fire.global_transform.origin)
	if distance > spray_range:
		state = "MOVE_TO_FIRE"

func _stop_extinguisher():
	if extinguisher and extinguisher.has_method("stop_spraying"):
		extinguisher.stop_spraying()
