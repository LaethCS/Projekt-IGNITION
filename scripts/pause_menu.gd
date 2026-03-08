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
@onready var btn_exit = $MainUI/ButtonSpalte/HBoxContainer/BtnExit
@onready var btn_about = $MainUI/ButtonSpalte/HBoxContainer/BtnAbout

# --- ABOUT MENU REFERENZEN ---
@onready var about_text = $MainUI/ButtonSpalte/HBoxContainer/BtnAbout/RichTextLabel
@onready var btn_back_about = $MainUI/ButtonSpalte/HBoxContainer/BtnAbout/BtnBack

# --- ZURÜCK BUTTONS ---
@onready var btn_back_level = $LevelUI/Lvl567AndBackBtn/BtnBackLevel
@onready var btn_back_audio = $AudioUI/BtnBackAudio 

# --- LEVEL BUTTONS ---
@onready var btn_lvl_1 = $LevelUI/Lvl1234/BtnLvl1
@onready var btn_lvl_2 = $LevelUI/Lvl567AndBackBtn/BtnLvl2
@onready var btn_lvl_3 = $LevelUI/Lvl1234/BtnLvl3
@onready var btn_lvl_4 = $LevelUI/Lvl567AndBackBtn/BtnLvl4
@onready var btn_lvl_5 = $LevelUI/Lvl1234/BtnLvl5
@onready var btn_lvl_6 = $LevelUI/Lvl567AndBackBtn/BtnLvl6
@onready var btn_lvl_7 = $LevelUI/Lvl1234/BtnLvl7

# --- SLIDERS ---
@onready var slider_fire = $AudioUI/FireRow/SliderFire
@onready var slider_music = $AudioUI/MusicRow/SliderMusic
@onready var slider_wind = $AudioUI/WindRow/SliderWind

# --- AUDIO BUS IDs ---
var bus_fire: int
var bus_music: int
var bus_wind: int

func _ready():
	hide() 
	
	bus_fire = AudioServer.get_bus_index("Fire")
	bus_music = AudioServer.get_bus_index("Music")
	bus_wind = AudioServer.get_bus_index("Wind")
	
	# About-Elemente beim Start verstecken
	about_text.hide()
	btn_back_about.hide()
	
	# Main Menu Buttons verbinden
	btn_resume.pressed.connect(resume_game)
	btn_levels.pressed.connect(show_level_menu)
	btn_audio.pressed.connect(show_audio_menu)
	btn_exit.pressed.connect(exit_game)
	
	# About Button ruft jetzt unser Menü auf!
	btn_about.pressed.connect(show_about_menu)
	
	# Back Buttons verbinden
	btn_back_level.pressed.connect(show_main_menu)
	btn_back_audio.pressed.connect(show_main_menu)
	
	# Back Button vom About-Menü verbinden
	btn_back_about.pressed.connect(hide_about_menu)
	
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
	if event.is_action_pressed("ui_cancel"): 
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

# --- AUDIO SLIDER FUNKTIONEN ---
func _on_fire_volume_changed(value: float):
	AudioServer.set_bus_volume_db(bus_fire, linear_to_db(value))
func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(bus_music, linear_to_db(value))
func _on_wind_volume_changed(value: float):
	AudioServer.set_bus_volume_db(bus_wind, linear_to_db(value))

# --- LEVEL LADEN ---
func load_level(path: String):
	resume_game() 
	get_tree().change_scene_to_file(path)

# --- MENÜ STEUERUNG ---
func pause_game():
	get_tree().paused = true
	hide_about_menu() 
	show_main_menu()
	update_level_info() 
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func resume_game():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

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

# --- ABOUT MENÜ STEUERUNG ---
func show_about_menu():
	# Wir verstecken die anderen Buttons
	btn_resume.hide()
	btn_levels.hide()
	btn_audio.hide()
	btn_exit.hide()
	
	# NEU: Level-Text ausblenden, damit der "About"-Text Platz hat!
	level_text.hide()
	
	# About-Button unsichtbar und nicht klickbar machen
	btn_about.self_modulate = Color(1, 1, 1, 0) 
	btn_about.disabled = true                   
	
	# Jetzt zeigen wir die Kinder (About-Text und Zurück-Button)!
	about_text.show()
	btn_back_about.show()

func hide_about_menu():
	# About-Text und Zurück-Button verstecken
	about_text.hide()
	btn_back_about.hide()
	
	# Alle Haupt-Buttons wieder einblenden
	btn_resume.show()
	btn_levels.show()
	btn_audio.show()
	btn_exit.show()
	
	# NEU: Level-Text wieder einblenden!
	level_text.show()
	
	# About-Button wieder sichtbar und normal machen
	btn_about.self_modulate = Color(1, 1, 1, 1) 
	btn_about.disabled = false


# --- LEVEL INFO TEXTE ---
func update_level_info():
	var current_scene_name = get_tree().current_scene.name
	
	match current_scene_name:
		"Level_1":
			level_text.text = "REGEL 1: WINDRICHTUNG\n\nGreife den Brand immer in Windrichtung an! Stellst du dich gegen den Wind, trifft dich das Feuer und du kassierst Blowback-Schaden."
		"Level_2":
			level_text.text = "REGEL 2: FLÄCHENBRÄNDE\n\nEin Brand breitet sich auf dem Boden aus. Wende die Regel an: Flächenbrände immer von vorne beginnend ablöschen. Arbeite dich langsam vor!"
		"Level_3":
			level_text.text = "REGEL 3: FLIESSBRÄNDE\n\nAchtung, brennende Flüssigkeit! Bei Tropf- und Fließbränden musst du die Technik ändern: Lösche hier immer von Oben nach Unten."
		"Level_4":
			level_text.text = "REGEL 4: WANDBRÄNDE\n\nDie Flammen klettern die Wände hoch! Wandbrände werden (im Gegensatz zu Fließbränden) immer von Unten nach Oben gelöscht."
		"Level_5":
			level_text.text = "REGEL 5: TEAMWORK\n\nDieses Feuer ist extrem hartnäckig. Denk an die Vorschrift: Bei großen Bränden ausreichend Feuerlöscher gleichzeitig einsetzen, nicht nacheinander!"
		"Level_6":
			level_text.text = "REGEL 6: RÜCKZÜNDUNG\n\nDreh dich niemals sofort um, wenn die Flammen weg sind! Achte auf versteckte Glutnester. Regel: Rückzündung beachten – das Feuer kann wieder aufflammen."
		"Level_7":
			level_text.text = "REGEL 7: WARTUNGS-FEHLER\n\nLeere Feuerlöscher gehören nicht auf den Boden! Bringe aufgebrauchte Löscher zum LKW und wirf sie dort ab."
		_: 
			level_text.text = "EINSATZ-INFO:\n\nBeachte die offiziellen Brandschutz-Regeln, lösche die Feuer und entkomme durch das Portal!"
func exit_game():
	get_tree().quit()
