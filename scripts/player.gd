extends CharacterBody3D

@export var mouse_sensitivity: float = 0.003
@export var blowback_strength: float = 6.0 
@export var blindness_speed: float = 3.0   

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D 
@onready var interact_ray = $Camera3D/RayCast3D
@onready var blindness_overlay = $CanvasLayer/BlindnessOverlay
@onready var game_over_text = get_node_or_null("CanvasLayer/GameOverText")
@onready var tutorial_label = get_node_or_null("CanvasLayer/TutorialLabel")

var blindness_intensity: float = 0.0
var blowback_velocity: Vector3 = Vector3.ZERO
var extinguisher: Node3D = null 
var current_wind_direction: Vector3 = Vector3.ZERO
var nearby_npc: Node3D = null # Behält die funktionierende Logik bei!

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if blindness_overlay:
		if "color" in blindness_overlay:
			blindness_overlay.color.a = 0.0
		else:
			blindness_overlay.modulate.a = 0.0
	if game_over_text:
		game_over_text.visible = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if camera:
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if event.is_action_pressed("interact"):
		var current_level = get_tree().current_scene.name
		
		# --- 1. PRIO: NPC INTERAKTION (Über deine funktionierenden Zonen) ---
		if nearby_npc != null:
			if current_level == "Level_5" and extinguisher != null and nearby_npc.extinguisher == null:
				nearby_npc.give_extinguisher(extinguisher)
				extinguisher = null 
				return 
			elif current_level == "Level_7" and nearby_npc.talked == false:
				nearby_npc.talked = true
				nearby_npc.start_dialogue()
				return 

		# --- 2. NORMAL: Löscher aufheben / fallenlassen (Über Laser) ---
		var target = null
		if interact_ray and interact_ray.is_colliding():
			target = interact_ray.get_collider()

		if extinguisher == null:
			if target and target.has_method("pick_up"):
				target.pick_up(self)
				extinguisher = target
		else:
			if extinguisher.has_method("drop"):
				extinguisher.drop()
			extinguisher = null

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_vel = direction * SPEED
	if current_wind_direction != Vector3.ZERO:
		target_vel += current_wind_direction * 1.5

	target_vel += blowback_velocity

	velocity.x = lerp(velocity.x, target_vel.x, delta * 10.0)
	velocity.z = lerp(velocity.z, target_vel.z, delta * 10.0)

	blowback_velocity = blowback_velocity.lerp(Vector3.ZERO, delta * 5.0)

	move_and_slide()

	if blindness_overlay:
		blindness_intensity -= delta * 0.8 
		blindness_intensity = clamp(blindness_intensity, 0.0, 1.0) 
		if "color" in blindness_overlay:
			blindness_overlay.color.a = blindness_intensity
		else:
			blindness_overlay.modulate.a = blindness_intensity
			
	# --- TUTORIAL TEXT ANZEIGEN ---
	if tutorial_label:
		tutorial_label.visible = false 
		var current_level = get_tree().current_scene.name
		
		# 1. NEUER TEXT FÜR NPC
		if nearby_npc != null:
			if current_level == "Level_5" and extinguisher != null and nearby_npc.extinguisher == null:
				tutorial_label.text = "[E] Feuerlöscher geben"
				tutorial_label.visible = true
			elif current_level == "Level_7" and nearby_npc.talked == false:
				tutorial_label.text = "[E] Reden"
				tutorial_label.visible = true

		# 2. Text für Löscher (Nur wenn wir nicht gerade mit dem NPC beschäftigt sind)
		if tutorial_label.visible == false:
			var target = null
			if interact_ray and interact_ray.is_colliding():
				target = interact_ray.get_collider()

			if target and target.has_method("pick_up") and extinguisher == null and target.get("show_tutorial") == true:
				tutorial_label.text = "[E] Aufheben"
				tutorial_label.visible = true
			elif extinguisher != null and extinguisher.get("show_tutorial") == true:
				tutorial_label.text = "[E] Fallenlassen"
				tutorial_label.visible = true

func get_current_wind_direction() -> Vector3:
	return current_wind_direction

func apply_blowback_effect():
	if not camera or current_wind_direction == Vector3.ZERO:
		return
	var delta = get_physics_process_delta_time()
	var look_dir = -camera.global_transform.basis.z.normalized()
	var wind_dir = current_wind_direction.normalized()
	var alignment = look_dir.dot(wind_dir)
	var severity = 0.0
	if alignment < -0.1: 
		severity = abs(alignment) 
	blindness_intensity += delta * blindness_speed * severity
	blindness_intensity = clamp(blindness_intensity, 0.0, 1.0)
	var push_dir = -look_dir 
	push_dir.y = 0 
	push_dir = push_dir.normalized()
	blowback_velocity = push_dir * (blowback_strength * severity)

func _on_wind_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("wind_zone"):
		current_wind_direction = area.wind_direction

func _on_wind_detector_area_exited(area: Area3D) -> void:
	if area.is_in_group("wind_zone"):
		current_wind_direction = Vector3.ZERO

func show_game_over():
	if game_over_text != null:
		game_over_text.visible = true
