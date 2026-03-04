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

func _calculate_rating(time: float, deaths: int) -> String:
	var penalty_time = time + (deaths * 10.0)
	
	#Bewertung basierend auf der berechneten Zeit
	if penalty_time <= 45.0:
		return ("S (Brandschutz-Meister)")
	elif penalty_time <= 55.0:
		return ("A (Sehr gut)")
	elif penalty_time <= 75.0:
		return ("B (Gut - Vorsicht vor dem Feuer!)")
	else: 
		return ("C (Bestanden - Achte auf \nden Sicherheitsabstand)")

func _level_complete():
	final_time = Time.get_unix_time_from_system() - start_time
	var deaths = GlobalStats.deaths_in_current_level
	var rating = _calculate_rating(final_time, deaths)
	
	win_label.text = "Level bestanden\nZeit: " +str(snapped(final_time, 0.1)) + " Sekunden \nBewertung: " +  rating
	win_label.visible = true
	
	win_sound.play()
	print("Win wird angezeigt")
	await get_tree().create_timer(4.0).timeout
	# Zurück zum Hauptmenü (Pfade anpassen!)
	GlobalStats.deaths_in_current_level = 0
	get_tree().change_scene_to_file("res://scenes/levelMenu.tscn")
