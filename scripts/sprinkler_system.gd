extends Node3D

@export var target_fire: Area3D = null # Welches Feuer soll gelöscht werden?
@export var sprinkler_power: float = 30.0 # Wie viel Schaden macht das Wasser?

var is_active: bool = false

@onready var water_particles = $WaterParticles

func _process(delta):
	# Wenn der Sprinkler an ist UND das Feuer noch existiert...
	if is_active and target_fire != null and is_instance_valid(target_fire):
		if not target_fire.is_dead:
			# ...zieht der Sprinkler dem Feuer permanent Leben ab!
			target_fire.extinguish(sprinkler_power * delta)

# Wird ausgelöst, wenn der Spieler in die Zone läuft
func _on_switch_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		
		# DER TRICK: Wir kehren den aktuellen Zustand einfach um!
		# Wenn is_active "false" war, wird es "true". Und umgekehrt.
		is_active = not is_active
		
		# Die Partikel passen sich dem neuen Zustand an
		if water_particles != null:
			water_particles.emitting = is_active
			
		# Feedback in der Konsole
		if is_active:
			print("SPRINKLER AKTIVIERT! Wasser marsch!")
		else:
			print("SPRINKLER DEAKTIVIERT! Wasser gestoppt.")
