extends Node3D

@export var target_fire: Node3D = null 
@export var sprinkler_power: float = 30.0 

var is_active: bool = false
var player_in_zone: bool = false

@onready var water_particles = $WaterParticles
@onready var interact_label = $Label3D 

func _ready():
	if interact_label:
		interact_label.hide()

func _process(delta):
	# Wenn der Sprinkler läuft, müssen wir das Feuer überwachen
	if is_active:
		if target_fire != null and is_instance_valid(target_fire):
			if not target_fire.is_dead:
				# Feuer brennt noch -> Wasser macht Schaden
				target_fire.extinguish(sprinkler_power * delta)
			else:
				# Feuer ist tot! -> Sprinkler automatisch stoppen
				stop_sprinkler()
		else:
			# Fallback: Falls das Feuer komplett aus dem Spiel gelöscht wurde
			stop_sprinkler()

# --- TASTENDRUCK ERKENNEN ---
func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		
		# Nur auslösen, wenn Spieler in Zone UND der Sprinkler NICHT schon läuft!
		if player_in_zone and not is_active:
			get_viewport().set_input_as_handled() 
			start_sprinkler()
			
			# Text verstecken, da man nicht mehr interagieren kann
			if interact_label != null and is_instance_valid(interact_label):
				interact_label.hide()

# Wir haben die toggle-Funktion in zwei klare Befehle aufgeteilt:
func start_sprinkler():
	is_active = true
	if water_particles != null:
		water_particles.emitting = true
	print("SPRINKLER AN! Wasser läuft, bis das Feuer aus ist...")

func stop_sprinkler():
	is_active = false
	if water_particles != null:
		water_particles.emitting = false
	print("SPRINKLER AUS! Das Feuer wurde erfolgreich gelöscht.")

# --- SPIELER BETRITT DIE ZONE ---
func _on_switch_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = true
		
		# Text NUR anzeigen, wenn der Sprinkler noch nicht ausgelöst wurde
		if not is_active and interact_label != null and is_instance_valid(interact_label):
			interact_label.text = "[E] Aktivieren"
			interact_label.show()

# --- SPIELER VERLÄSST DIE ZONE ---
func _on_switch_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = false
		
		# Text einfach nur verstecken
		if interact_label != null and is_instance_valid(interact_label):
			interact_label.hide()
