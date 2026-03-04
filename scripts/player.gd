extends CharacterBody3D

# --- EINSTELLUNGEN ---
@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.003
@export var extinguish_power = 1.5 # Wie schnell geht das Feuer aus?

# --- REFERENZEN ---
@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var foam_particles = $Camera3D/FoamParticles
@onready var blindness_overlay = $CanvasLayer/BlindnessOverlay
@onready var extinguisher_sound = $ExtinguisherSound # <-- NEU: Hier ist dein Sound-Node!
@onready var game_over_text = $CanvasLayer/GameOverText # <-- NEU: Hier ist dein Game Over Text!

# --- VARIABLEN ---
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_wind_zone: Area3D = null # Speichert die Zone, in der wir sind
var blowback_count: int = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Maus verstecken

func _input(event):
	# Maus-Bewegung (Kamera drehen)
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# 1. Bewegung (Standard Character Controller)
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

	move_and_slide()
	
	# 2. FEUERLÖSCHER LOGIK
	handle_fire_extinguisher(delta)

# --- DIE HAUPTLOGIK FÜR DEIN PROJEKT ---
func handle_fire_extinguisher(delta):
	if Input.is_action_pressed("fire"):
		foam_particles.emitting = true
		
		# --- NEU: SOUND STARTEN ---
		# Prüfen, ob der Sound gerade läuft, damit er nicht jeden Frame neu startet
		if not extinguisher_sound.playing:
			extinguisher_sound.play()
		
		# A. Wind-Check (Die wichtigste Regel!)
		if check_wind_direction_is_safe():
			# Wind ist gut -> Wir können löschen
			blindness_overlay.color.a = move_toward(blindness_overlay.color.a, 0.0, delta) # Sicht klären
			
			# Feuer treffen?
			if raycast.is_colliding():
				var target = raycast.get_collider()
				# SICHERHEITS-CHECK 1: Ist target "null"?
				if target == null:
					return # Abbrechen, wir haben nichts Greifbares getroffen
				
				# SICHERHEITS-CHECK 2: Wurde das Objekt gerade gelöscht?
				# (Das ist der wichtigste Check bei queue_free!)
				if not is_instance_valid(target):
					return # Das Objekt ist "tot", Finger weg!
				
				print("Ich treffe: ", target.name)
				
				if target.has_method("extinguish"):
					target.extinguish(extinguish_power)
				else:
					print("Objekt ist kein Feuer (keine extinguish Methode)")
			else:
				print("Raycast trifft gar nichts bzw nur Luft")
		else:
			# Wind ist schlecht -> Bestrafung!
			apply_blowback_effect(delta)
			
	else:
		# Maustaste wird NICHT gedrückt -> Alles aus!
		foam_particles.emitting = false
		blindness_overlay.color.a = move_toward(blindness_overlay.color.a, 0.0, delta)
		
		# --- NEU: SOUND STOPPEN ---
		extinguisher_sound.stop()

# Prüft: Stehe ich im Wind? Wenn ja, schaue ich in die richtige Richtung?
func check_wind_direction_is_safe() -> bool:
	if current_wind_zone == null:
		return true # Kein Wind, also sicher
	
	# Skalarprodukt (Dot Product):
	# 2. Wohin schaut der Spieler? (Minus Z ist Vorwärts in Godot!)
	var look_dir = -camera.global_transform.basis.z.normalized()
	var wind_dir = current_wind_zone.wind_direction.normalized()
	
	var alignment = look_dir.dot(wind_dir)
	print("Blick: ", look_dir, " | Wind: ", wind_dir, " | Ergebnis: ", alignment)
	
	# Wenn alignment > 0: Wir schauen mit dem Wind (Gut)
	# Wenn alignment < 0: Wir schauen gegen den Wind (Schlecht)
	# Wir erlauben eine kleine Toleranz (-0.2)
	if alignment < -0.2:
		return false
	else:
		return true

func apply_blowback_effect(delta):
	# 1. Sicht verdecken (Weißer Nebel)
	print("ALARM! BLOWBACK AKTIV!")
	blindness_overlay.color.a = move_toward(blindness_overlay.color.a, 1.0, delta * 2.0)
	blowback_count +=1
	# 2. Optional: Partikel fliegen zurück (Visueller Trick)
	# Das ist etwas komplexer, für den Anfang reicht das Overlay

func _on_wind_detector_area_entered(area: Area3D) -> void:
	# Prüfen, ob das eine WindZone ist (via Name oder Gruppe)
	if area.name.begins_with("WindZone"): # Simpler Check
		current_wind_zone = area
		print("Windzone betreten!")

func _on_wind_detector_area_exited(area: Area3D) -> void:
	if area == current_wind_zone:
		current_wind_zone = null
		print("Windzone verlassen!")

# --- NEU: GAME OVER FUNKTION ---
func show_game_over():
	if game_over_text != null:
		game_over_text.visible = true
