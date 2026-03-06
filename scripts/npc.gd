extends CharacterBody3D

# ----------------------
# CONFIG
# ----------------------
@export var move_speed: float = 3.5
@export var spray_range: float = 2.5

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
	if not is_on_floor():
		velocity.y -= 9.8 * delta
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
	var dir = (next_pos - global_transform.origin)
	dir.y = 0
	dir = dir.normalized()

	# Move
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	move_and_slide()

	# Rotate smoothly toward movement direction
	if dir.length() > 0.1:
		var target_basis = Basis().looking_at(dir, Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)

# ----------------------
# USE EXTINGUISHER
# ----------------------
func _use_extinguisher(delta):
	if not target_fire or target_fire.is_dead:
		_stop_extinguisher()
		state = "IDLE"
		return

	# Face fire (Y axis only)
	var fire_dir = target_fire.global_transform.origin - global_transform.origin
	fire_dir.y = 0
	fire_dir = fire_dir.normalized()

	if fire_dir.length() > 0.1:
		var target_basis = Basis().looking_at(fire_dir, Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)

	# Spray
	if extinguisher.has_method("start_spraying"):
		extinguisher.start_spraying()

	# Check distance
	var distance = global_transform.origin.distance_to(target_fire.global_transform.origin)
	if distance > spray_range:
		state = "MOVE_TO_FIRE"

func _stop_extinguisher():
	if extinguisher and extinguisher.has_method("stop_spraying"):
		extinguisher.stop_spraying()
