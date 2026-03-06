extends CharacterBody3D

# --- EINSTELLUNGEN (Im Godot-Editor anpassbar!) ---
@export var mouse_sensitivity: float = 0.003
@export var blowback_strength: float = 6.0 # Wie stark der Löscher dich zurückschiebt
@export var blindness_speed: float = 3.0   # Wie schnell das Bild weiß wird

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- REFERENZEN ---
@onready var camera = $Camera3D 
@onready var interact_ray = $Camera3D/RayCast3D
@onready var blindness_overlay = get_node_or_null("CanvasLayer/BlindnessOverlay")
@onready var game_over_text = get_node_or_null("CanvasLayer/GameOverText")

# --- STATE ---
var blindness_intensity: float = 0.0
var blowback_velocity: Vector3 = Vector3.ZERO
var extinguisher: Node3D = null 
var current_wind_direction: Vector3 = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Start-Zustand: Kein Nebel, kein Game Over
	if blindness_overlay:
		if "color" in blindness_overlay:
			blindness_overlay.color.a = 0.0
		else:
			blindness_overlay.modulate.a = 0.0
	if game_over_text:
		game_over_text.visible = false

func _unhandled_input(event):
	# Kamera drehen
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if camera:
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	# --- AUFHEBEN UND FALLENLASSEN MIT 'E' ---
	if event.is_action_pressed("interact"):
		if extinguisher == null:
			if interact_ray and interact_ray.is_colliding():
				var target = interact_ray.get_collider()
				if target and target.has_method("pick_up"):
					target.pick_up(self)
					extinguisher = target
		else:
			if extinguisher.has_method("drop"):
				extinguisher.drop()
			extinguisher = null

func _physics_process(delta):
	# 1. Gravitation
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Springen
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Laufen (Spieler-Input)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Start-Geschwindigkeit (nur was der Spieler tippt)
	var target_vel = direction * SPEED

	# Level-Wind addieren (zieht den Spieler sanft in Windrichtung)
	if current_wind_direction != Vector3.ZERO:
		target_vel += current_wind_direction * 1.5

	# Blowback (Rückstoß vom Löscher) addieren
	target_vel += blowback_velocity

	# WEICHE BEWEGUNG: Verhindert ruckartiges Fliegen und macht das Laufen super geschmeidig
	velocity.x = lerp(velocity.x, target_vel.x, delta * 10.0)
	velocity.z = lerp(velocity.z, target_vel.z, delta * 10.0)

	# Blowback sanft abklingen lassen, wenn man nicht mehr sprüht
	blowback_velocity = blowback_velocity.lerp(Vector3.ZERO, delta * 5.0)

	move_and_slide()

	# --- 5. BLINDNESS EFFEKT ABKLINGEN LASSEN ---
	if blindness_overlay:
		# Jeden Frame klärt sich die Sicht ein wenig
		blindness_intensity -= delta * 0.8 
		blindness_intensity = clamp(blindness_intensity, 0.0, 1.0) 
		
		if "color" in blindness_overlay:
			blindness_overlay.color.a = blindness_intensity
		else:
			blindness_overlay.modulate.a = blindness_intensity


# ============================================================
# FUNKTIONEN FÜR DEN FEUERLÖSCHER
# ============================================================

func get_current_wind_direction() -> Vector3:
	return current_wind_direction

func apply_blowback_effect():
	if not camera or current_wind_direction == Vector3.ZERO:
		return
		
	var delta = get_physics_process_delta_time()
	
	# Berechnen, aus welchem Winkel der Spieler in den Wind schaut
	var look_dir = -camera.global_transform.basis.z.normalized()
	var wind_dir = current_wind_direction.normalized()
	
	# 'alignment' ist negativ, wenn man GEGEN den Wind schaut (-1.0 = exakt dagegen)
	var alignment = look_dir.dot(wind_dir)
	
	var severity = 0.0
	if alignment < -0.1: # Kleine Toleranz
		severity = abs(alignment) 
		
	# 1. BLINDNESS DYNAMISCH AUFBAUEN (bis 100% / 1.0)
	blindness_intensity += delta * blindness_speed * severity
	blindness_intensity = clamp(blindness_intensity, 0.0, 1.0)
	
	# 2. RÜCKSTOSS BERECHNEN (ohne Fliegen)
	# FEHLER BEHOBEN: Wir müssen uns natürlich NACH HINTEN (-look_dir) pushen!
	var push_dir = -look_dir 
	push_dir.y = 0 # Verhindert weiterhin das Fliegen!
	push_dir = push_dir.normalized()
	
	# Rückstoß setzen. Je direkter man in den Wind schaut, desto stärker drückt es.
	blowback_velocity = push_dir * (blowback_strength * severity)


# ============================================================
# SIGNALE
# ============================================================

func _on_wind_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("wind_zone"):
		current_wind_direction = area.wind_direction

func _on_wind_detector_area_exited(area: Area3D) -> void:
	if area.is_in_group("wind_zone"):
		current_wind_direction = Vector3.ZERO

# --- GAME OVER FUNKTION ---
func show_game_over():
	if game_over_text != null:
		game_over_text.visible = true
