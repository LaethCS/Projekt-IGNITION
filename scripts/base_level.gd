extends Node3D
class_name BaseLevel 

var total_fires: int = 0
var max_fires: int = 0
var start_time: float = 0.0
var final_time: float = 0.0

@export var gold_time: float = 20.0
@export var silver_time: float = 30.0

@export var level_portal: Area3D 
@onready var tank_label = $CanvasLayer/FireCounterLabel 
@onready var win_label = $WinUI/WinLabel 
@onready var win_sound = $WinUI/WinLabel/win_soundeffect 

func _ready():
	if GlobalStats.deaths_in_current_level == 0:
		GlobalStats.level_start_time = Time.get_unix_time_from_system()
	start_time = GlobalStats.level_start_time
	
	var all_fires = get_tree().get_nodes_in_group("Fires")
	total_fires = all_fires.size()
	max_fires = total_fires 
	
	print("Level gestartet! Gefundene Feuer: ", total_fires) 
	
	# Text in Level 7 komplett verstecken, in anderen Leveln anzeigen
	if tank_label:
		if name == "Level_7":
			tank_label.visible = false
		else:
			tank_label.visible = true
			tank_label.text = "Löscher suchen..."
			tank_label.modulate = Color(1, 1, 1) # Weiß
	
	for fire in all_fires:
		if fire.has_signal("fire_extinguished"):
			fire.fire_extinguished.connect(_on_fire_extinguished)

func _on_fire_extinguished():
	total_fires -= 1
	print("Noch verbleibende Feuer: ", total_fires)
	
	if total_fires <= 0:
		_level_complete()

func _calculate_rating(time: float) -> String:
	if time <= gold_time:
		return "S (Brandschutz-Profi!)"
	elif time <= silver_time:
		return "A (Sehr gut)"
	else: 
		return "B (Gut gemacht)"

func _level_complete():
	final_time = Time.get_unix_time_from_system() - start_time
	var rating = _calculate_rating(final_time)
	
	if win_label:
		win_label.get_parent().visible = true 
		win_label.text = "Level bestanden\nZeit: " + str(snapped(final_time, 0.1)) + " Sekunden \nBewertung: " + rating
		win_label.visible = true  
		
	if win_sound:
		win_sound.play()
		
	print("Win wird angezeigt. Portal öffnet sich!")
	
	if level_portal and level_portal.has_method("activate_portal"):
		level_portal.activate_portal()
		
	# Portal-Info anzeigen (aber in Level 7 bleibt das UI unsichtbar)
	if tank_label and name != "Level_7":
		tank_label.text = "Ausgang offen!"
		tank_label.modulate = Color(0, 1, 0) # Grün
	
	if GlobalStats:
		GlobalStats.deaths_in_current_level = 0
