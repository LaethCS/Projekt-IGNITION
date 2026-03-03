extends Area3D
signal fire_extinguished # Dieses Signal wird gesendet, wenn das Feuer gelöscht ist

@export var max_health: float = 100.0
var current_health: float

@export var fire_source: Area3D = null 
@export var auto_heal_rate: float = 0.0 
@export var can_reignite: bool = false 

var is_dead: bool = false 

# --- Glut-Variablen für Level 6 ---
var is_ember: bool = false
var ember_timer: float = 0.0
var ember_health: float = 50.0 # So viel muss "nachgekühlt" werden

@onready var light = $OmniLight3D
@onready var particles = $GPUParticles3D
@onready var fire_sound = $fire_sound 
@onready var extinguish_sound = %extinguish_sound

func _ready():
	current_health = max_health

func _process(delta):
	# --- LEVEL 3 & 4: Die Regeneration ---
	if fire_source != null and is_instance_valid(fire_source):
		if fire_source.current_health > 0 and not fire_source.is_dead:
			if not is_dead and current_health < max_health:
				current_health += 50.0 * delta
				current_health = min(current_health, max_health)
				_update_visuals()

	# --- LEVEL 5: Selbstheilung ---
	if auto_heal_rate > 0 and current_health > 0 and not is_dead and not is_ember:
		current_health += auto_heal_rate * delta
		current_health = min(current_health, max_health)
		_update_visuals()

	# --- LEVEL 6: Der Glut-Timer tickt! ---
	if is_ember:
		ember_timer += delta
		if ember_timer >= 3.0: # Nach 3 Sekunden ohne ausreichendes Kühlen...
			print("RÜCKZÜNDUNG! Feuer ist wieder da!")
			is_ember = false
			current_health = max_health
			ember_timer = 0.0
			ember_health = 50.0
			particles.emitting = true
			_update_visuals()
			
			# --- NEU FÜR LEVEL 6 SOUNDS: Knistern wieder starten! ---
			if not fire_sound.playing:
				fire_sound.play()

func _update_visuals():
	var health_percent = current_health / max_health
	health_percent = max(health_percent, 0.0) 
	light.light_energy = health_percent
	particles.amount_ratio = health_percent

# Diese Funktion wird vom Feuerlöscher aufgerufen
func extinguish(amount: float):
	if is_dead:
		return 
		
	# --- LEVEL 6: Nachkühlen der Glut ---
	if is_ember:
		ember_health -= amount
		if ember_health <= 0:
			die() # Jetzt ist es WIRKLICH tot!
		return # Wichtig: Hier abbrechen, damit der normale Schaden nicht berechnet wird

	# --- Normaler Feuer-Schaden ---
	current_health -= amount
	_update_visuals()
	
	if current_health <= 0:
		if fire_source != null and is_instance_valid(fire_source) and not fire_source.is_dead:
			pass # Unsterblich wegen Quelle
		elif can_reignite and not is_ember:
			# --- LEVEL 6 FALLE SCHNAPPT ZU ---
			is_ember = true
			particles.emitting = false 
			light.light_energy = 0.2 
			
			# --- NEU FÜR LEVEL 6 SOUNDS: Die Täuschung! ---
			if fire_sound.playing:
				fire_sound.stop() # Knistern stoppen
			extinguish_sound.play() # Zischen abspielen, als wäre es gelöscht!
			
			print("Feuer scheint aus... aber Glut ist noch heiß!")
		else:
			die()

func die():
	is_dead = true 
	is_ember = false
	print("Feuer endgültig gelöscht! Sound startet jetzt...")
	
	particles.emitting = false
	light.visible = false
	$MeshInstance3D.visible = false 
	
	$CollisionShape3D.set_deferred("disabled", true)
	
	if fire_sound.playing:
		fire_sound.stop()
	
	# Wenn der Sound nicht schon von der Falle läuft, spielen wir ihn ab
	if not extinguish_sound.playing:
		extinguish_sound.play()
		
 	
	await extinguish_sound.finished
	fire_extinguished.emit()
	queue_free()

func _on_damage_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		if (current_health > 0 or is_ember) and not is_dead: 
			if body.has_method("show_game_over"):
				body.show_game_over()
			
			print("DU BIST VERBRANNT! Level wird in 0.5s neu gestartet...")
			await get_tree().create_timer(0.5).timeout
			get_tree().reload_current_scene()
