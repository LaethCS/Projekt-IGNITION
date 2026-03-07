extends Control

# --- DEIN STORY-TEXT ---
var story_text: String = "Das alte Chemiewerk brennt...\nDer Wind ist unberechenbar und die Zeit wird knapp.\nBringe leere Löscher zum LKW zurück.\n\nDu bist unsere letzte Hoffnung."

@onready var label = $Label
var current_char: int = 0
var text_speed: float = 0.05 # Wie schnell die Buchstaben erscheinen (kleiner = schneller)
var timer: float = 0.0

func _ready():
	# Text ins Label packen, aber alle Buchstaben unsichtbar machen
	label.text = story_text
	label.visible_characters = 0

func _process(delta):
	# Buchstaben langsam einen nach dem anderen einblenden
	if current_char < story_text.length():
		timer += delta
		if timer >= text_speed:
			timer = 0.0
			current_char += 1
			label.visible_characters = current_char
	else:
		# Wenn der Text fertig ist, lassen wir ihn kurz stehen und warten auf Input
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			start_game()

# Optional: Spieler kann das Intro mit Linksklick oder Leertaste überspringen
func _unhandled_input(event):
	if event.is_action_pressed("interact") or event.is_action_pressed("fire") or event.is_action_pressed("jump"):
		if current_char < story_text.length():
			# Text sofort komplett anzeigen
			current_char = story_text.length()
			label.visible_characters = -1
		else:
			start_game()

func start_game():
	# HIER DEINEN LEVEL-NAMEN EINTRAGEN!
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
