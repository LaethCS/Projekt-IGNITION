extends CanvasLayer

# --- UI REFERENZEN ---
@onready var main_ui = $MainUI
@onready var level_ui = $LevelUI
@onready var audio_ui = $AudioUI
@onready var level_text = $MainUI/InfoBox/LevelText

# --- MAIN BUTTONS ---
@onready var btn_resume = $MainUI/ButtonSpalte/BtnResume
@onready var btn_levels = $MainUI/ButtonSpalte/BtnLevels
@onready var btn_audio = $MainUI/ButtonSpalte/BtnAudio
@onready var btn_exit = $MainUI/ButtonSpalte/BtnExit

# --- ZURÜCK BUTTONS ---
@onready var btn_back_level = $LevelUI/BtnBackLevel
@onready var btn_back_audio = $AudioUI/BtnBackAudio

# --- LEVEL BUTTONS ---
@onready var btn_lvl_1 = $LevelUI/BtnLvl1
@onready var btn_lvl_2 = $LevelUI/BtnLvl2
@onready var btn_lvl_3 = $LevelUI/BtnLvl3
@onready var btn_lvl_4 = $LevelUI/BtnLvl4
@onready var btn_lvl_5 = $LevelUI/BtnLvl5
@onready var btn_lvl_6 = $LevelUI/BtnLvl6
@onready var btn_lvl_7 = $LevelUI/BtnLvl7

# --- SLIDERS (Angepasst auf die neuen HBoxContainer!) ---
@onready var slider_fire = $AudioUI/FireRow/SliderFire
@onready var slider_music = $AudioUI/MusicRow/SliderMusic
@onready var slider_wind = $AudioUI/WindRow/SliderWind

# --- AUDIO BUS IDs ---
var bus_fire: int
var bus_music: int
var bus_wind: int

func _ready():
	hide() # Menü am Start verstecken
	
	# Audio-Busse abrufen (Achte darauf, dass sie im Godot-Audio-Reiter exakt so heißen!)
	bus_fire = AudioServer.get_bus_index("Fire")
	bus_music = AudioServer.get_bus_index("Music")
	bus_wind = AudioServer.get_bus_index("Wind")
	
	# Main Menu Buttons verbinden
	btn_resume.pressed.connect(resume_game)
	btn_levels.pressed.connect(show_level_menu)
	btn_audio.pressed.connect(show_audio_menu)
	btn_exit.pressed.connect(exit_game)
	
	# Back Buttons verbinden
	btn_back_level.pressed.connect(show_main_menu)
	btn_back_audio.pressed.connect(show_main_menu)
	
	# Alle 7 Level Buttons verbinden
	btn_lvl_1.pressed.connect(func(): load_level("res://scenes/level_1.tscn"))
	btn_lvl_2.pressed.connect(func(): load_level("res://scenes/level_2.tscn"))
	btn_lvl_3.pressed.connect(func(): load_level("res://scenes/level_3.tscn"))
	btn_lvl_4.pressed.connect(func(): load_level("res://scenes/level_4.tscn"))
	btn_lvl_5.pressed.connect(func(): load_level("res://scenes/level_5.tscn"))
	btn_lvl_6.pressed.connect(func(): load_level("res://scenes/level_6.tscn"))
	btn_lvl_7.pressed.connect(func(): load_level("res://scenes/level_7.tscn"))
	
	# Slider Signale verbinden
	slider_fire.value_changed.connect(_on_fire_volume_changed)
	slider_music.value_changed.connect(_on_music_volume_changed)
	slider_wind.value_changed.connect(_on_wind_volume_changed)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Escape Taste
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

# --- AUDIO SLIDER FUNKTIONEN ---
func _on_fire_volume_changed(value: float):
	# linear_to_db wandelt 0.0 - 1.0 in Godot-Dezibel um
	AudioServer.set_bus_volume_db(bus_fire, linear_to_db(value))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(bus_music, linear_to_db(value))

func _on_wind_volume_changed(value: float):
	AudioServer.set_bus_volume_db(bus_wind, linear_to_db(value))

# --- LEVEL LADEN ---
func load_level(path: String):
	resume_game() # Erst das Spiel entpausieren, sonst ist das neue Level eingefroren!
	get_tree().change_scene_to_file(path)

# --- MENÜ STEUERUNG ---
func pause_game():
	get_tree().paused = true
	show_main_menu()
	update_level_info() # Aktualisiert den Text rechts passend zum Level
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Maus sichtbar machen

func resume_game():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Maus im Spiel verstecken

func show_main_menu():
	main_ui.show()
	level_ui.hide()
	audio_ui.hide()

func show_level_menu():
	main_ui.hide()
	level_ui.show()

func show_audio_menu():
	main_ui.hide()
	audio_ui.show()

func exit_game():
	get_tree().quit()

# --- LEVEL INFO TEXTE ---
func update_level_info():
	var current_scene_name = get_tree().current_scene.name
	
	match current_scene_name:
		"Level_1":
			# Regel 1: Brand in Windrichtung angreifen
			level_text.text = "REGEL 1: WINDRICHTUNG\n\nGreife den Brand immer in Windrichtung an! Stellst du dich gegen den Wind, trifft dich das Feuer und du kassierst Blowback-Schaden."
		
		"Level_2":
			# Regel 2: Flächenbrände vorn beginnend ablöschen
			level_text.text = "REGEL 2: FLÄCHENBRÄNDE\n\nEin Brand breitet sich auf dem Boden aus. Wende die Regel an: Flächenbrände immer von vorne beginnend ablöschen. Arbeite dich langsam vor!"
		
		"Level_3":
			# Regel 3: Tropf- und Fließbrände von oben nach unten löschen
			level_text.text = "REGEL 3: FLIESSBRÄNDE\n\nAchtung, brennende Flüssigkeit! Bei Tropf- und Fließbränden musst du die Technik ändern: Lösche hier immer von Oben nach Unten."
		
		"Level_4":
			# Regel 4: Wandbrände von unten nach oben löschen
			level_text.text = "REGEL 4: WANDBRÄNDE\n\nDie Flammen klettern die Wände hoch! Wandbrände werden (im Gegensatz zu Fließbränden) immer von Unten nach Oben gelöscht."
		
		"Level_5":
			# Regel 5: Ausreichend Feuerlöscher gleichzeitig einsetzen
			level_text.text = "REGEL 5: TEAMWORK\n\nDieses Feuer ist extrem hartnäckig. Denk an die Vorschrift: Bei großen Bränden ausreichend Feuerlöscher gleichzeitig einsetzen, nicht nacheinander!"
		
		"Level_6":
			# Regel 6: Rückzündung beachten
			level_text.text = "REGEL 6: RÜCKZÜNDUNG\n\nDreh dich niemals sofort um, wenn die Flammen weg sind! Achte auf versteckte Glutnester. Regel: Rückzündung beachten – das Feuer kann wieder aufflammen."
		
		"Level_7":
			# Regel 7: Nach Gebrauch nicht wieder aufhängen
			level_text.text = "REGEL 7: WARTUNGS-FEHLER\n\nLeere Feuerlöscher gehören nicht auf den Boden! Bringe aufgebrauchte Löscher zum LKW und wirf sie dort ab."
		
		_: 
			# Fallback
			level_text.text = "EINSATZ-INFO:\n\nBeachte die offiziellen Brandschutz-Regeln, lösche die Feuer und entkomme durch das Portal!"
