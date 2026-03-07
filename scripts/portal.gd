extends Area3D

@export var next_level_path: String = "res://scenes/levelMenu.tscn"
var is_active: bool = false
var portal_material: StandardMaterial3D

@onready var mesh = $MeshInstance3D
@onready var text_label = $Label3D
@onready var blocker_col = $BlockerWall/CollisionShape3D 

func _ready():
	is_active = false 
	
	# Neues Material für das Portal erstellen (Rot)
	portal_material = StandardMaterial3D.new()
	portal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	portal_material.albedo_color = Color(1, 0, 0, 0.8) 
	portal_material.emission_enabled = true          
	portal_material.emission = Color(1, 0, 0)
	portal_material.emission_energy_multiplier = 4.0 

	if mesh:
		mesh.material_override = portal_material

func activate_portal():
	is_active = true
	
	if text_label:
		text_label.text = "Ausgang offen!"
		text_label.modulate = Color(0, 1, 0) # Grün
		
	if portal_material:
		# Material auf Grün ändern
		portal_material.albedo_color = Color(0.0, 1.0, 0.0, 0.8) 
		portal_material.emission = Color(0.0, 1.0, 0.0) 
			
	if blocker_col:
		blocker_col.set_deferred("disabled", true)

func _on_body_entered(body):
	if body.name == "Player" and is_active:
		get_tree().change_scene_to_file(next_level_path)
