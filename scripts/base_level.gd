extends Node3D
class_name BaseLevel # Das ist extrem wichtig, damit andere Skripte davon erben können!

var total_fires: int = 0
var max_fires: int = 0
var start_time: float = 0.0
var final_time: float = 0.0

@export var gold_time: float = 20.0
@export var silver_time: float = 30.0

# NEU: Referenzen für Portal und Feuer-Zähler
@export var level_portal: Area3D 
@onready var fire_counter_label = $CanvasLayer/FireCounterLabel # Falls du den HUD-Zähler schon hast
@onready var win_label = $WinUI/WinLabel 
@onready var win_sound = $WinUI/WinLabel/win_soundeffect 

func _ready():
	if GlobalStats.deaths_in_current_level == 0:
		# Frischer Start: Wir merken uns die jetzige Uhrzeit global!
		GlobalStats.level_start_time = Time.get_unix_time_from_system()
	start_time = GlobalStats.level_start_time
	var all_fires = get_tree().get_nodes_in_group("Fires")
	total_fires = all_fires.size()
	max_fires = total_fires # Wir merken uns, wie viele es am Anfang waren!
	
	print("Level gestartet! Gefundene Feuer: ", total_fires) 
	update_fire_ui() # Zähler am Start aktualisieren
	
	for fire in all_fires:
		if fire.has_signal("fire_extinguished"):
			fire.fire_extinguished.connect(_on_fire_extinguished)

# NEU: Aktualisiert den Text auf dem Bildschirm
func update_fire_ui():
	if fire_counter_label:
		fire_counter_label.text = "Verbleibende Feuer: " + str(total_fires) + " / " + str(max_fires)

func _on_fire_extinguished():
	total_fires -= 1
	print("Noch verbleibende Feuer: ", total_fires)
	update_fire_ui()
	
	if total_fires <= 0:
		_level_complete()

# Standard-Bewertung
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
	
	# Win-UI anzeigen
	if win_label:
		win_label.get_parent().visible = true 
		win_label.text = "Level bestanden\nZeit: " + str(snapped(final_time, 0.1)) + " Sekunden \nBewertung: " + rating
		win_label.visible = true    
		
	if win_sound:
		win_sound.play()
		
	print("Win wird angezeigt. Portal öffnet sich!")
	
	# NEU: Portal aktivieren, anstatt automatisch das Level zu beenden!
	if level_portal and level_portal.has_method("activate_portal"):
		level_portal.activate_portal()
		
	# Zähler-Text anpassen
	if fire_counter_label:
		fire_counter_label.text = "Alle Feuer gelöscht! Finde das Portal!"
		fire_counter_label.modulate = Color(0, 1, 0) # Text wird grün
	
	# Statistiken für das nächste Level zurücksetzen
	if GlobalStats:
		GlobalStats.deaths_in_current_level = 0
		
