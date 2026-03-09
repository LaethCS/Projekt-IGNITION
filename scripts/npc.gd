extends CharacterBody3D

@export var move_speed: float = 3.5
@export var spray_range: float = 2.5
@export var is_talkable: bool = false

var extinguisher: Node = null
var target_fire: Node = null
var state: String = "IDLE"
var talked := false

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var pickup_detector: Area3D = $PickupDetector
@onready var dialogue_area = $DialogueArea
@onready var dialogueManager = get_tree().current_scene.get_node_or_null("DialogueUI")

func _ready():
	# Wir nutzen wieder DEINE originalen Zonen!
	pickup_detector.body_entered.connect(_on_area_entered)
	pickup_detector.body_exited.connect(_on_area_exited)
	dialogue_area.body_entered.connect(_on_area_entered)
	dialogue_area.body_exited.connect(_on_area_exited)

func _on_area_entered(body):
	if body.name == "Player":
		body.nearby_npc = self # Sagt dem Spieler: Du bist nah genug für "E"!
	# Original-Funktion: Falls ein Löscher reingeworfen wird, fängt er ihn!
	elif body.is_in_group("extinguisher") and extinguisher == null:
		give_extinguisher(body)

func _on_area_exited(body):
	if body.name == "Player" and body.get("nearby_npc") == self:
		body.nearby_npc = null # Spieler ist weggegangen

func start_dialogue():
	if is_talkable and dialogueManager:
		var dialogue = [
			"Hey! Gute Arbeit da draußen!",
			"Du hast das Feuer wirklich \nschnell unter Kontrolle gebracht.",
			"Die Feuerlöscher sind jetzt allerdings leer...",
			"Was sollen wir mit den leeren Dingern machen?",
			"Bring sie am besten zum Feuerwehrzug\n dort drüben."
		]
		dialogueManager.start(dialogue)

func give_extinguisher(fire_extinguisher: Node) -> void:
	extinguisher = fire_extinguisher
	extinguisher.pick_up(self)
	state = "IDLE"

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

func _find_fire():
	var fires = get_tree().get_nodes_in_group("Fires")
	if fires.is_empty():
		return
	for f in fires:
		if f and not f.is_dead:
			target_fire = f
			break
	if target_fire:
		nav.target_position = target_fire.global_transform.origin
		state = "MOVE_TO_FIRE"

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
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	move_and_slide()
	if dir.length() > 0.1:
		var target_basis = Basis().looking_at(dir, Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)

func _use_extinguisher(delta):
	if not target_fire or target_fire.is_dead:
		_stop_extinguisher()
		state = "IDLE"
		return
	var fire_dir = target_fire.global_transform.origin - global_transform.origin
	fire_dir.y = 0
	fire_dir = fire_dir.normalized()
	if fire_dir.length() > 0.1:
		var target_basis = Basis().looking_at(fire_dir, Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * 6.0)
	if extinguisher and extinguisher.has_method("start_spraying"):
		extinguisher.start_spraying()
	var distance = global_transform.origin.distance_to(target_fire.global_transform.origin)
	if distance > spray_range:
		state = "MOVE_TO_FIRE"

func _stop_extinguisher():
	if extinguisher and extinguisher.has_method("stop_spraying"):
		extinguisher.stop_spraying()
