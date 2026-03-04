extends CharacterBody3D

# --- EINSTELLUNGEN ---
@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.003

# --- REFERENZEN ---
@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var blindness_overlay = $CanvasLayer/BlindnessOverlay
@onready var game_over_text = $CanvasLayer/GameOverText

# --- NEU: Pickup System ---
var held_object: Node3D = null

# --- WIND ---
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_wind_zone: Area3D = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	wind_detector.area_entered.connect(_on_wind_entered)
	wind_detector.area_exited.connect(_on_wind_exited)

func _input(event):
	# Kamera drehen
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# --- INTERACT (Pickup / Drop) ---
	if event.is_action_pressed("interact"):
		if held_object:
			if held_object.has_method("drop"):
				held_object.drop()
			held_object = null
		else:
			if raycast.is_colliding():
				var obj = raycast.get_collider()
				if obj and obj.has_method("pick_up"):
					obj.pick_up(self)
					held_object = obj

func _physics_process(delta):

	# Bewegung
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if blindness_overlay.color.a > 0:
		blindness_overlay.color.a -= 0.05
	move_and_slide()

	# --- BENUTZEN ---
	if held_object and held_object.has_method("handle_use"):
		held_object.handle_use(delta)


# --- WIND SYSTEM ---
@onready var wind_detector = $WindDetector
var wind_zones_inside: Array = []

func _on_wind_entered(area: Area3D):
	if area.is_in_group("wind_zone"):
		wind_zones_inside.append(area)

func _on_wind_exited(area: Area3D):
	if area.is_in_group("wind_zone"):
		wind_zones_inside.erase(area)

func get_current_wind_direction() -> Vector3:
	if wind_zones_inside.is_empty():
		return Vector3.ZERO
	return wind_zones_inside[-1].wind_direction

# ---  Blowback ---
func apply_blowback_effect():
	if blindness_overlay.color.a < 1:
		blindness_overlay.color.a += 0.1

func show_game_over():
	if game_over_text:
		game_over_text.visible = true
