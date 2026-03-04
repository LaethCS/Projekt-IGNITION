extends Node3D

var total_fires = 0

#Text und Soundeffect bei Level Completion
@onready var win_label = $WinUI/WinLabel 
@onready var win_sound = $WinUI/WinLabel/win_soundeffect 


#Timer Startpunkt
var start_time: float = 0.0
var final_time: float = 0.0
# Schwellenwerte für die Bewertung (in Sekunden)
@export var gold_time: float = 40.0
@export var silver_time: float = 50.0

func _ready():
	#Timer wird gestartet zu Anfang des Spiels
	start_time = Time.get_unix_time_from_system()
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

func _calculate_rating(time: float ) -> String:
	if time <= gold_time:
		return "S (Brandschutz-Profi!)"
	elif time <= silver_time:
		return "A (Sehr gut)"
	else: 
		return "B (Gut gemacht)"

func _level_complete():
	final_time = Time.get_unix_time_from_system() - start_time
	var rating = _calculate_rating(final_time)
	
	win_label.text = "Level bestanden\nZeit: " +str(snapped(final_time, 0.1)) + " Sekunden \nBewertung: " +  rating
	win_label.visible = true
	
	win_sound.play()
	print("Win wird angezeigt")
	await get_tree().create_timer(4.0).timeout
	# Zurück zum Hauptmenü (Pfade anpassen!)
	get_tree().change_scene_to_file("res://scenes/levelMenu.tscn")
