extends Node3D
@onready var win_label = $WinUI/WinLabel
@onready var win_sound = $WinUI/WinLabel/win_soundeffect
var total_fires = 0

func _ready():
	# Wir suchen alle Kinder, die "Fire" im Namen haben oder zur Gruppe "Fires" gehören
	var all_fires = get_tree().get_nodes_in_group("Fires")
	total_fires = all_fires.size()
	
	for fire in all_fires:
		# Wir verbinden das Signal jedes Feuers mit dieser Szene
		fire.fire_extinguished.connect(_on_fire_extinguished)

func _on_fire_extinguished():
	total_fires -= 1
	print("Noch verbleibende Feuer: ", total_fires)
	
	if total_fires <= 0:
		_level_complete()

func _level_complete():
	# Ein kurzer Moment warten, damit der Spieler den Erfolg sieht
	await get_tree().create_timer(2.0).timeout
	win_label.visible = true
	win_sound.play()
	await get_tree().create_timer(2.0).timeout
	# Zurück zum Hauptmenü (Pfade anpassen!)
	get_tree().change_scene_to_file("res://scenes/levelMenu.tscn")
