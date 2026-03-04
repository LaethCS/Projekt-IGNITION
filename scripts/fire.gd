extends Node3D

# ============================================================
# CONFIG
# ============================================================

@export var max_health: float = 100.0
@export var fire_source: Node = null
@export var auto_heal_rate: float = 0.0
@export var can_reignite: bool = false

# Wind influence multiplier
@export var wind_direction_strength: float = 0.4

# ============================================================
# STATE
# ============================================================

var current_health: float
var is_dead: bool = false

# Ember system
var is_ember: bool = false
var ember_timer: float = 0.0
var ember_health: float = 50.0
const EMBER_REIGNITE_TIME := 3.0

# Wind
var current_wind: Area3D = null
var base_direction: Vector3 = Vector3.UP
var base_velocity: float = 3.0

# ============================================================
# NODES
# ============================================================

@onready var light: OmniLight3D = $Visuals/OmniLight3D
@onready var particles: GPUParticles3D = $Visuals/FireParticles
@onready var fire_sound: AudioStreamPlayer3D = $fire_sound
@onready var extinguish_sound: AudioStreamPlayer3D = %extinguish_sound
@onready var damage_zone: Area3D = $DamageZone
@onready var wind_detector: Area3D = $WindDetector


# ============================================================
# READY
# ============================================================

func _ready():
	current_health = max_health
	
	damage_zone.body_entered.connect(_on_damage_zone_body_entered)
	wind_detector.area_entered.connect(_on_wind_entered)
	wind_detector.area_exited.connect(_on_wind_exited)

	# Make particle material unique per instance
	if particles.process_material:
		particles.process_material = particles.process_material.duplicate()
	var mat = particles.process_material
	if mat:
		base_direction = mat.direction
		base_velocity = mat.initial_velocity_min

# ============================================================
# PROCESS
# ============================================================

func _process(delta):

	if is_dead:
		return

	_flicker_light()
	_handle_regeneration(delta)
	_handle_ember(delta)
	_handle_wind(delta)


# ============================================================
# CORE SYSTEMS
# ============================================================

func extinguish(amount: float):

	if is_dead:
		return

	# Ember cooling phase
	if is_ember:
		ember_health -= amount
		if ember_health <= 0:
			die()
		return

	current_health -= amount
	_update_visuals()

	if current_health <= 0:
		_try_enter_ember_or_die()


func die():
	is_dead = true
	is_ember = false

	particles.emitting = false
	light.visible = false
	damage_zone.get_node("CollisionShape3D").set_deferred("disabled", true)

	if fire_sound.playing:
		fire_sound.stop()

	if not extinguish_sound.playing:
		extinguish_sound.play()

	await extinguish_sound.finished
	queue_free()


# ============================================================
# EMBER SYSTEM
# ============================================================

func _try_enter_ember_or_die():

	# Protected by fire source
	if fire_source and is_instance_valid(fire_source):
		if fire_source.current_health > 0:
			return

	if can_reignite:
		is_ember = true
		ember_timer = 0.0
		particles.emitting = false
		light.light_energy = 0.2

		if fire_sound.playing:
			fire_sound.stop()

		extinguish_sound.play()
	else:
		die()


func _handle_ember(delta):

	if not is_ember:
		return

	ember_timer += delta

	if ember_timer >= EMBER_REIGNITE_TIME:
		_reignite()


func _reignite():
	is_ember = false
	current_health = max_health
	ember_timer = 0.0
	ember_health = 50.0

	particles.emitting = true
	fire_sound.play()
	_update_visuals()


# ============================================================
# REGENERATION
# ============================================================

func _handle_regeneration(delta):

	if is_ember:
		return

	# Linked source regeneration
	if fire_source and is_instance_valid(fire_source):
		if fire_source.current_health > 0 and current_health < max_health:
			current_health += 50.0 * delta

	# Passive regeneration
	if auto_heal_rate > 0 and current_health > 0:
		current_health += auto_heal_rate * delta

	current_health = clamp(current_health, 0.0, max_health)
	_update_visuals()


# ============================================================
# WIND SYSTEM (Velocity BASED)
# ============================================================

func _on_wind_entered(area: Area3D):
	if area.is_in_group("wind_zone"):
		current_wind = area

func _on_wind_exited(area: Area3D):
	if area == current_wind:
		current_wind = null

func _handle_wind(delta):

	var mat = particles.process_material
	if mat == null:
		return

	if current_wind:
		var wind_dir = -current_wind.wind_direction.normalized()
		var strength = current_wind.wind_strength

		# Blend direction smoothly
		mat.direction = mat.direction.lerp(
			Vector3.UP + wind_dir * 0.6 * strength,
			delta * 3.0
		)

		# Increase velocity slightly with wind
		mat.initial_velocity_min = lerp(
			mat.initial_velocity_min,
			base_velocity + strength,
			delta * 3.0
		)

	else:
		# Return to normal
		mat.direction = mat.direction.lerp(
			base_direction,
			delta * 3.0
		)

		mat.initial_velocity_min = lerp(
			mat.initial_velocity_min,
			base_velocity,
			delta * 3.0
		)


# ============================================================
# VISUALS
# ============================================================

func _update_visuals():
	var percent = clamp(current_health / max_health, 0.0, 1.0)
	light.light_energy = percent * 3.0
	particles.amount_ratio = percent


func _flicker_light():
	if light.visible:
		light.light_energy += randf() * 0.2


# ============================================================
# DAMAGE ZONE
# ============================================================

func _on_damage_zone_body_entered(body: Node3D):

	if body.name != "Player":
		return

	if (current_health > 0 or is_ember) and not is_dead:

		if body.has_method("show_game_over"):
			body.show_game_over()

		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
