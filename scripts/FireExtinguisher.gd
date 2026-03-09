extends RigidBody3D

# --- CONFIG ---
@export var extinguish_power: float = 1.0   
@export var spray_range: float = 5.0        
@export var max_amount: float = 100.0       
@export var infinite_ammo: bool = true      
@export var depletion_rate: float = 10.0    
@export var blowback_strength: float = 2.0  
@export var show_tutorial: bool = false 

# --- STATE ---
var current_amount: float
var is_held: bool = false
var holder: Node3D = null
var current_wind_zone: Area3D = null

# --- NODES ---
@onready var particles = $NozzlePosition/FoamParticles
@onready var spray_ray = $NozzlePosition/SprayRay
@onready var collision = $CollisionShape3D
@onready var sound = $ExtinguisherSound
@onready var camera = null

func _ready() -> void:
	current_amount = max_amount
	spray_ray.enabled = false
	particles.emitting = false

func _physics_process(delta: float) -> void:
	if not is_held:
		return

	var is_player = holder != null and holder.has_method("get_current_wind_direction")
	var is_safe = true
	
	if is_player:
		is_safe = check_wind_direction_is_safe()

	var is_firing = Input.is_action_pressed("fire")
	
	if is_firing and (current_amount > 0 or infinite_ammo):
		_start_spraying()
		if is_player and not is_safe:
			if holder.has_method("apply_blowback_effect"):
				holder.apply_blowback_effect()
	else:
		_stop_spraying() 

	if spray_ray.enabled:
		if not infinite_ammo:
			current_amount -= depletion_rate * delta
			current_amount = max(current_amount, 0)

		if is_safe and spray_ray.is_colliding():
			_process_hit(spray_ray.get_collider())

	if is_player:
		_update_tank_ui()

# --- FUNKTION FÜR DAS UI ---
func _update_tank_ui() -> void:
	var current_level = get_tree().current_scene
	if current_level and "tank_label" in current_level and current_level.tank_label:
		var label = current_level.tank_label
		
		# WICHTIG: In Level 7 ignorieren wir das UI komplett!
		if current_level.name == "Level_7":
			label.visible = false
			return
			
		label.visible = true # Sicherstellen, dass es sichtbar ist
		
		if infinite_ammo:
			label.text = "Tank: Unendlich"
			label.modulate = Color(0.2, 0.8, 1.0) # Schönes Hellblau
		else:
			var percent = int((current_amount / max_amount) * 100)
			label.text = "Tank: " + str(percent) + " %"
			
			if percent > 50:
				label.modulate = Color(1, 1, 1) # Weiß
			elif percent > 20:
				label.modulate = Color(1, 1, 0) # Gelb
			else:
				label.modulate = Color(1, 0.2, 0.2) # Rot

# --- PICK UP ---
func pick_up(holder_node: Node3D) -> void:
	if is_held and holder:
		if "extinguisher" in holder:
			holder.extinguisher = null
	
	is_held = true
	holder = holder_node
	
	if holder.has_node("Camera3D/HoldPosition"):
		camera = holder.get_node("Camera3D")
		var hold_pos = camera.get_node("HoldPosition")
		get_parent().remove_child(self)
		hold_pos.add_child(self)
		transform = Transform3D.IDENTITY
		scale = Vector3.ONE
	else:
		var hold_pos = holder.get_node_or_null("HoldPosition")
		if hold_pos:
			get_parent().remove_child(self)
			hold_pos.add_child(self)
			transform = Transform3D.IDENTITY
			scale = Vector3.ONE
		else:
			get_parent().remove_child(self)
			holder.add_child(self)
			transform.origin = Vector3(0, 1.0, 0) 

	freeze = true
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)

# --- DROP ---
func drop() -> void:
	if holder == null:
		return

	is_held = false
	particles.emitting = false
	spray_ray.enabled = false

	# Text wieder auf Standard zurücksetzen (Aber NICHT in Level 7!)
	var current_level = get_tree().current_scene
	if current_level and "tank_label" in current_level and current_level.tank_label:
		if current_level.name != "Level_7":
			current_level.tank_label.text = "Löscher suchen..."
			current_level.tank_label.modulate = Color(1, 1, 1)
			current_level.tank_label.visible = true

	var root = get_tree().current_scene
	get_parent().remove_child(self)
	root.add_child(self)

	var drop_offset = Vector3(0, 1.0, -1.0)
	global_transform.origin = holder.global_transform.origin + holder.global_transform.basis * drop_offset

	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	freeze = false

	linear_velocity = holder.global_transform.basis.z * -1.5

	holder = null
	camera = null
	if sound.playing:
		sound.stop()

# --- SPRAY START / STOP ---
func _start_spraying() -> void:
	if not particles.emitting:
		particles.restart()
		
	particles.emitting = true
	spray_ray.enabled = true
	if not sound.playing:
		sound.play()

func _stop_spraying() -> void:
	particles.emitting = false
	spray_ray.enabled = false
	if sound.playing:
		sound.stop()

# --- HANDLE HIT ---
func _process_hit(hit_obj: Object) -> void:
	if not hit_obj or not is_instance_valid(hit_obj):
		return
	
	if hit_obj.has_method("extinguish"):
		hit_obj.extinguish(extinguish_power)
	elif hit_obj.get_parent() and hit_obj.get_parent().is_in_group("Fires"):
		hit_obj.get_parent().extinguish(extinguish_power)

# --- WIND CHECK ---
func check_wind_direction_is_safe() -> bool:
	if holder == null:
		return true
	
	if camera == null:
		return true
		
	if not holder.has_method("get_current_wind_direction"):
		return true
	
	var wind_dir = holder.get_current_wind_direction()
	if wind_dir == Vector3.ZERO:
		return true
	
	var look_dir = -camera.global_transform.basis.z.normalized()
	var alignment = look_dir.dot(wind_dir.normalized())

	return alignment >= -0.2
	
# --- REFILL ---
func refill(amount: float) -> void:
	current_amount += amount
	current_amount = min(current_amount, max_amount)

# --- WIND ZONE SIGNALS ---
func _on_wind_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("wind_zone"):
		current_wind_zone = area

func _on_wind_detector_area_exited(area: Area3D) -> void:
	if area == current_wind_zone:
		current_wind_zone = null
