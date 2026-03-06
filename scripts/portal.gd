extends Area3D

@export var next_level_path: String = "res://scenes/levelMenu.tscn"
var is_active: bool = false

@onready var mesh = $MeshInstance3D
@onready var text_label = $Label3D
# NEU: Wir holen uns die Kollisions-Box der Wand!
@onready var blocker_col = $BlockerWall/CollisionShape3D 

func _ready():
	pass

func activate_portal():
	is_active = true
	text_label.text = "Ausgang offen!"
	text_label.modulate = Color(0, 1, 0) 
	
	var mat = mesh.get_active_material(0)
	if mat:
		mat.albedo_color = Color(0.0, 1.0, 0.5, 0.5) 
		mat.emission = Color(0.0, 1.0, 0.5) 
		
	# NEU: Die feste Wand wird ausgeschaltet! Der Spieler kann durch.
	if blocker_col:
		blocker_col.set_deferred("disabled", true)

func _on_body_entered(body):
	# Dieser Text erscheint in der Konsole, sobald IRGENDETWAS das Portal berührt
	print("Etwas hat das Portal berührt: ", body.name)
	
	# Wir prüfen auf "Player" (Achte genau auf die Groß-/Kleinschreibung!)
	if body.name == "Player":
		print("Der Spieler ist im Portal!") # Erkennt er den Spieler?
		
		if is_active:
			print("Portal ist aktiv! Wechsle zu: ", next_level_path)
			var error = get_tree().change_scene_to_file(next_level_path)
			if error != OK:
				print("FEHLER: Konnte die Szene nicht laden! Ist der Pfad richtig?")
		else:
			print("Portal ist noch blockiert!")
